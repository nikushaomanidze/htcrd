<?php

namespace App\Http\Resources\Api;

use App\Http\Resources\SubCategoryResource;
use Illuminate\Http\Resources\Json\JsonResource;

class CategoryResource extends JsonResource
{
    public function toArray($request)
    {
        return [
            'id'                => $this->id,
            'icon'              => nullCheck($this->icon),
            'parent_id'         => (int)$this->parent_id,
            'slug'              => $this->slug,
            'banner'            => $this->popular_banner,
            'title'             => $this->getTranslation('title',apiLanguage($request->lang)),
            'image'             => $this->popular_image,
            'sub_categories'    => SubCategoryResource::collection($this->childCategories),
            'latlong'           => $this->getTranslation('meta_description',apiLanguage($request->lang)),
            'category_filter'   => $this->getTranslation('category_filter',apiLanguage($request->lang)),
            'number'            => $this->getTranslation('number',apiLanguage($request->lang)),
            'soc_fb'            => $this->getTranslation('soc_fb',apiLanguage($request->lang)),
            'soc_yt'            => $this->getTranslation('soc_yt',apiLanguage($request->lang)),
            'soc_in'            => $this->getTranslation('soc_in',apiLanguage($request->lang)),
            
            
        ];
    }
}
