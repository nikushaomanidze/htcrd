<?php

namespace App\Repositories\Admin\Addon;
use App\Http\Resources\SiteResource\ProductResource;
use App\Http\Resources\SiteResource\VideoResource;
use App\Models\Product;
use App\Models\VideoShopping;
use App\Models\VideoShoppingLanguage;
use App\Repositories\Interfaces\Admin\Addon\VideoShoppingInterface;
use App\Traits\ImageTrait;
use App\Traits\SlugTrait;
use GuzzleHttp\Client;
use Illuminate\Support\Facades\DB;
use Sentinel;

class VideoShoppingRepository implements VideoShoppingInterface
{
    use ImageTrait;
    use SlugTrait;

    public function get($id)
    {
        return VideoShopping::find($id);
    }

    public function all()
    {
        return VideoShopping::latest();
    }
    public function getByLang($id, $lang)
    {
        if($lang == null):
            $videoByLang = VideoShoppingLanguage::with('videoShopping')->where('lang', 'en')->where('video_shopping_id', $id)->first();
        else:
            $videoByLang = VideoShoppingLanguage::with('videoShopping')->where('lang', $lang)->where('video_shopping_id', $id)->first();
            if (blank($videoByLang)):
                $videoByLang = VideoShoppingLanguage::with('videoShopping')->where('lang', 'en')->where('video_shopping_id', $id)->first();
                $videoByLang['translation_null'] = 'not-found';
            endif;
        endif;

        return $videoByLang;
    }

    public function store($request)
    {
            $video_shopping                             = new VideoShopping();
            $video_shopping->slug                       = $this->getSlug($request->title, $request->slug);

            if ($request->thumbnail != ''):
                $video_shopping->thumbnail_id           = $request->thumbnail;
                $video_shopping->thumbnail              = $this->getImageWithRecommendedSize($request->thumbnail, '299','536');
            else:
                $video_shopping->thumbnail              = [];
            endif;

            $video_shopping->user_id                    = Sentinel::getUser()->user_type == 'seller' ? authId() : 1;

            $video_shopping->video_type                 = $request->video_type;
            $video_shopping->style                      = $request->style;
            $video_shopping->video_url                  = $request->video_url;
            $video_shopping->product_ids                = $request->has('product_id') ? $request->product_id : [];
            $video_shopping->enable_related_product     = $request->has('enable_related_product') ? 1 : 0;
            $video_shopping->is_live                    = $request->has('is_live') ? 1 : 0;
            $video_shopping->save();

            if ($request->lang == ''):
                $request['lang']    = 'en';
            endif;

            $this->storeLang($video_shopping->id,$request);
            return true;
    }

    public function storeLang($video_id,$request){
        $video_shopping_lang                         = new VideoShoppingLanguage();
        $video_shopping_lang->video_shopping_id      = $video_id;
        $video_shopping_lang->lang                   = $request->lang;
        $video_shopping_lang->title                  = $request->title;
        $video_shopping_lang->meta_title             = $request->meta_title;
        $video_shopping_lang->meta_description       = $request->meta_description;
        $video_shopping_lang->save();
    }

    public function update($request)
    {
            $video_shopping                             = $this->get($request->video_id);
            $video_shopping->slug                       = $this->getSlug($request->title, $request->slug);

            if ($request->thumbnail != ''):
                $video_shopping->thumbnail_id           = $request->thumbnail;
                $video_shopping->thumbnail              = $this->getImageWithRecommendedSize($request->thumbnail, '299','536');
            else:
                $video_shopping->thumbnail              = [];
            endif;


            $video_shopping->video_type                 = $request->video_type;
            $video_shopping->style                      = $request->style;
            $video_shopping->video_url                  = $request->video_url;
            $video_shopping->product_ids                = $request->has('product_id') ? $request->product_id : [];
            $video_shopping->enable_related_product     = $request->has('enable_related_product') ? 1 : 0;
            $video_shopping->is_live                    = $request->has('is_live') ? 1 : 0;
            $video_shopping->save();

            if ($request->video_lang_id == '') :
                $this->storeLang($video_shopping->id,$request);
            else:
                $this->updateLang($video_shopping->id,$request);
            endif;
            return true;
    }

    public function updateLang($video_id,$request){

        $video_shopping_lang                         = VideoShoppingLanguage::find($request->video_lang_id);
        $video_shopping_lang->video_shopping_id      = $video_id;
        $video_shopping_lang->lang                   = $request->lang != '' ? $request->lang : 'en';
        $video_shopping_lang->title                  = $request->title;
        $video_shopping_lang->meta_title             = $request->meta_title;
        $video_shopping_lang->meta_description       = $request->meta_description;
        $video_shopping_lang->save();
    }


    public function paginate($limit,$request,$for = '')
    {
        $data = $this->all()
            ->when(Sentinel::getUser()->user_type != 'admin' || Sentinel::getUser()->user_type == 'staff', function ($q){
                $q->where('user_id', Sentinel::getUser()->id);
            })
            ->when($request->q != null, function ($q) use ($request){
                $q->whereHas('videoShoppingLanguages',function ($qu) use ($request){
                    $qu->where('title', 'LIKE', '%'.$request->q.'%');

                });
            })
            ->paginate($limit);

        return $data;
    }
    public function statusChange($request)
    {
            $video            = $this->get($request['id']);
            $video->status    = $request['status'];
            $video->save();
            return true;
    }

    public function shopBySlug($slug)
    {
        $related_products = $videos = [];
        $take = 6;

        $video = VideoShopping::where('slug',$slug)->active()->first();

        if ($video)
        {
            $products = ProductResource::collection(Product::whereIn('id',$video->product_ids)->withCount('reviews')->UserCheck()->IsWholesale()->IsStockOut()
                ->selectRaw('id,price,special_discount,minimum_order_quantity,current_stock,special_discount_type,special_discount_start,special_discount_end,rating,total_sale,thumbnail,slug,reward,current_stock')
                ->ProductPublished()->orderBy('total_sale', 'desc')->when(settingHelper('seller_video_shopping') != 1,function ($query){
                    $query->where('user_id',1);
                })->get());


            if ($video->enable_related_product == 1 && count($products) > 0)
            {
                if ($video->style == 'style_4')
                {
                    $take = 4;
                }

                $related_products = ProductResource::collection(Product::withCount('reviews')->UserCheck()->IsWholesale()->IsStockOut()
                    ->selectRaw('id,price,special_discount,minimum_order_quantity,current_stock,special_discount_type,special_discount_start,special_discount_end,rating,total_sale,thumbnail,slug,reward,current_stock')
                    ->ProductPublished()->orderBy('total_sale', 'desc')->where('category_id',$products->pluck('category_id')->toArray())->take($take)->get());
            }
            else{
                $videos = VideoResource::collection($this->all()->where('id','!=',$video->id)->take(6)->get());
            }
        }
        else{
            return [
                'popular_videos'    => VideoResource::collection($this->all()->take(6)->get())
            ];
        }

        $video_url = $video->video_url;


        return [
            'id'                    => $video->id,
            'slug'                  => $video->slug,
            'style'                 => $video->style,
            'video_type'            => $video->video_type,
            'video_url'             => $video->video_type == 'mp4' ? $video_url : getVideoId($video->video_type, $video_url),
            'thumbnail'             => getFileLink('299x536',$video->thumbnail),
            'title'                 => $video->getTranslation('title',languageCheck()),
            'products'              => $products,
            'related_products'      => $related_products,
            'has_related_products'  => (bool)$video->enable_related_product,
            'popular_videos'        => $videos,
        ];
    }


    public function shopBySlugApi($slug)
    {
        $related_products = $videos = [];
        $take = 6;

        $video = VideoShopping::where('slug',$slug)->active()->first();

        if ($video)
        {
            $products = \App\Http\Resources\ProductResource::collection(Product::whereIn('id',$video->product_ids)->withCount('reviews')->UserCheck()->IsWholesale()->IsStockOut()
                ->selectRaw('id,price,special_discount,minimum_order_quantity,current_stock,special_discount_type,special_discount_start,special_discount_end,rating,total_sale,thumbnail,slug,reward,current_stock')
                ->ProductPublished()->orderBy('total_sale', 'desc')->when(settingHelper('seller_video_shopping') != 1,function ($query){
                    $query->where('user_id',1);
                })->get());


            if ($video->enable_related_product == 1 && count($products) > 0)
            {
                if ($video->style == 'style_4')
                {
                    $take = 4;
                }

                $related_products = \App\Http\Resources\ProductResource::collection(Product::withCount('reviews')->UserCheck()->IsWholesale()->IsStockOut()
                    ->selectRaw('id,price,special_discount,minimum_order_quantity,current_stock,special_discount_type,special_discount_start,special_discount_end,rating,total_sale,thumbnail,slug,reward,current_stock')
                    ->ProductPublished()->orderBy('total_sale', 'desc')->where('category_id',$products->pluck('category_id')->toArray())->take($take)->get());
            }
            else{
                $videos = VideoResource::collection($this->all()->where('id','!=',$video->id)->take(6)->get());
            }
        }
        else{
            return [
                'popular_videos'    => VideoResource::collection($this->all()->take(6)->get())
            ];
        }

        $video_url = $video->video_url;

        return [
            'id'                    => $video->id,
            'slug'                  => $video->slug,
            'style'                 => $video->style,
            'video_type'            => $video->video_type,
            'video_url'             => $video->video_type == 'mp4' ? $video_url : getVideoId($video->video_type, $video_url),
            'thumbnail'             => getFileLink('299x536',$video->thumbnail),
            'title'                 => $video->getTranslation('title',languageCheck()),
            'products'              => $products,
            'related_products'      => $related_products,
            'has_related_products'  => (bool)$video->enable_related_product,
            'popular_videos'        => $videos,
        ];
    }
}
