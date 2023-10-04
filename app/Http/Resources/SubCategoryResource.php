<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;


class SubCategoryResource extends JsonResource
{
    public function toArray($request)
    {
        return [
            'id'                => $this->id,
            'icon'              => nullCheck($this->icon),
            'parent_id'         => (int)$this->parent_id,
            'slug'              => $this->slug,
            'banner'            => $this->popular_banner,
            'title'             => $this->getTranslation('title',languageCheck()),
            'image'             => $this->popular_image,
            // 'child_categories'  => CategoryWithoutChildResource::collection($this->childCategories),
            'latlong'           => $this->getTranslation('meta_description',apiLanguage($request->lang)),
            'category_filter'   => $this->getTranslation('category_filter',apiLanguage($request->lang)),
            'number'            => $this->getTranslation('number',apiLanguage($request->lang)),
            'soc_fb'            => $this->getTranslation('soc_fb',apiLanguage($request->lang)),
            'soc_yt'            => $this->getTranslation('soc_yt',apiLanguage($request->lang)),
            'soc_in'            => $this->getTranslation('soc_in',apiLanguage($request->lang)),
        ];
    }
}
