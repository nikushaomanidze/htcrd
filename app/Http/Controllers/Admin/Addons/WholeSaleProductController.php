<?php

namespace App\Http\Controllers\Admin\Addons;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\Product\ProductStoreRequest;
use App\Http\Requests\Admin\Product\ProductUpdateRequest;
use App\Repositories\Admin\VatTaxRepository;
use App\Repositories\Interfaces\Admin\LanguageInterface;
use App\Repositories\Interfaces\Admin\Product\AttributeInterface;
use App\Repositories\Interfaces\Admin\Product\BrandInterface;
use App\Repositories\Interfaces\Admin\Product\CategoryInterface;
use App\Repositories\Interfaces\Admin\Product\ColorInterface;
use App\Repositories\Interfaces\Admin\Product\ProductInterface;
use App\Repositories\Interfaces\Admin\SellerInterface;
use App\Repositories\Interfaces\Admin\WholesaleProductInterface;
use Brian2694\Toastr\Facades\Toastr;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class WholeSaleProductController extends Controller
{
    protected $products;
    protected $wholesale_products;
    protected $categories;
    protected $brands;
    protected $colors;
    protected $attributes;
    protected $vat_tax;
    protected $languages;
    protected $sellers;

    public function __construct(ProductInterface $products,
                                WholesaleProductInterface $wholesale_products,
                                CategoryInterface $categories,
                                BrandInterface $brands,
                                ColorInterface $colors,
                                AttributeInterface $attributes,
                                VatTaxRepository $vat_tax,
                                SellerInterface $sellers,
                                LanguageInterface $languages)
    {
        $this->products             = $products;
        $this->wholesale_products   = $wholesale_products;
        $this->categories           = $categories;
        $this->brands               = $brands;
        $this->colors               = $colors;
        $this->attributes           = $attributes;
        $this->vat_tax              = $vat_tax;
        $this->languages            = $languages;
        $this->sellers              = $sellers;
    }
    public function wholesaleProducts(Request $request, $status = null){
        try {
            $products               = $this->products->paginate($request, $status ,get_yrsetting('paginate'),'wholesale');
            $selected_category      = isset($request->c) ? $this->categories->get($request->c) : null;
            $selected_seller        = isset($request->sl) ? $this->sellers->getSeller($request->sl) : null;
            return view('admin.wholesale-product.products', compact('status','products','selected_category','selected_seller'));
        } catch (\Exception $e) {
            Toastr::error($e->getMessage());
            return back();
        }
    }
    public function create(Request $request){

        $categories                 = $this->categories->allCategory()->where('parent_id', null)->where('status',1);
        $brands                     = $this->brands->all()->where('status',1)->get();
        $colors                     = $this->colors->all()->where('lang', 'en')->get();
        $attributes                 = $this->attributes->all()->where('lang', 'en')->get();
        $r                          = $request->r != ''? $request->r : $request->server('HTTP_REFERER');
        return view('admin.wholesale-product.form',compact('categories','brands','colors','attributes','r'));
    }

    public function store(ProductStoreRequest $request)
    {
        if (isDemoServer()):
            Toastr::info(__('This function is disabled in demo server.'));
            return redirect()->back();
        endif;
        DB::beginTransaction();
        try {
            $this->wholesale_products->store($request);
            Toastr::success(__('Created Successfully'));
            DB::commit();
            return redirect()->route('wholesale.products');
        } catch (\Exception $e) {
            DB::rollBack();
            Toastr::error($e->getMessage());
            return redirect()->back();
        }
    }
    public function edit($id, Request $request){
        try {
            $languages  = $this->languages->all()->orderBy('id', 'asc')->get();

            $lang       = $request->lang != '' ? $request->lang : \App::getLocale();
            if ($this->products->get($id) && $product_language = $this->products->getByLang($id, $lang)):
                $categories     = $this->categories->allCategory()->where('parent_id', null)->where('status',1);
                $brands         = $this->brands->all()->where('status',1)->get();
                $colors         = $this->colors->all()->where('lang', 'en')->get();
                $attributes     = $this->attributes->all()->where('lang', 'en')->get();
                $wholesalePrices     = $this->wholesale_products->wholesalePrices($id);
                $r              = $request->r != ''? $request->r : $request->server('HTTP_REFERER');

                return view('admin.wholesale-product.edit',compact('languages', 'lang','product_language','categories','brands','attributes','colors','r','wholesalePrices'));
            else:
                Toastr::error(__('Not found'));
                return back();
            endif;
        } catch (\Exception $e){
            Toastr::error($e->getMessage());
            return back();
        }
    }
    public function update(ProductUpdateRequest $request)
    {
        if (isDemoServer()):
            Toastr::info(__('This function is disabled in demo server.'));
            return redirect()->back();
        endif;
        DB::beginTransaction();
        try {
            $this->wholesale_products->update($request);
            Toastr::success(__('Updated Successfully'));
            DB::commit();
            return redirect($request->r);
        } catch (\Exception $e) {
            DB::rollBack();
            Toastr::error($e->getMessage());
            return redirect()->back();
        }
    }

    public function cloneWholesaleProduct($id, Request $request){
        try {
            $languages  = $this->languages->all()->orderBy('id', 'asc')->get();

            $lang       = $request->lang != '' ? $request->lang : \App::getLocale();
            if ($this->products->get($id) && $product_language = $this->products->getByLang($id, $lang)):
                $categories         = $this->categories->allCategory()->where('parent_id', null)->where('status',1);
                $brands             = $this->brands->all()->where('status',1)->get();
                $colors             = $this->colors->all()->where('lang', 'en')->get();
                $attributes         = $this->attributes->all()->where('lang', 'en')->get();
                $wholesalePrices    = $this->wholesale_products->wholesalePrices($id);
                $r                  = $request->r != ''? $request->r : $request->server('HTTP_REFERER');
                $clone              = 1;

                return view('admin.wholesale-product.edit',
                    compact(
                        'languages',
                        'lang',
                        'product_language',
                        'categories','brands',
                        'attributes',
                        'colors',
                        'r',
                        'wholesalePrices',
                        'clone'
                    ));
            else:
                Toastr::error(__('Not found'));
                return back();
            endif;
        } catch (\Exception $e){
            Toastr::error($e->getMessage());
            return back();
        }
    }
    public function storeCloneWholesaleProduct(ProductStoreRequest $request){
        if (isDemoServer()):
            Toastr::info(__('This function is disabled in demo server.'));
            return redirect()->back();
        endif;

        DB::beginTransaction();
        try {
            $this->wholesale_products->store($request);
            Toastr::success(__('Created Successfully'));
            DB::commit();
            return redirect($request->r);
        } catch (\Exception $e) {
            DB::rollBack();
            Toastr::error($e->getMessage());
            return redirect()->back();
        }
    }

    public function setting(){
        try {
            return view('admin.wholesale-product.setting');
        } catch (\Exception $e) {
            Toastr::error( $e->getMessage());
            return back();
        }
    }
}
