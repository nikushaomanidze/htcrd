<?php

namespace App\Http\Resources\SiteResource;

use Illuminate\Http\Resources\Json\JsonResource;

class TopCategoryResource extends JsonResource
{
    public function toArray($request)
    {
        return [
            'id'                => $this->id,
            'slug'              => $this->slug,
            'title'             => $this->getTranslation('title',languageCheck()),
            'popular_image'     => $this->popular_image,
            'popular_banner'    => $this->popular_banner,
            'top_image'         => $this->top_image,
            'latlong'           => $this->getTranslation('meta_description',apiLanguage($request->lang)),
            'category_filter'   => $this->getTranslation('category_filter',apiLanguage($request->lang)),
            'number'            => $this->getTranslation('number',apiLanguage($request->lang)),
            'soc_fb'            => $this->getTranslation('soc_fb',apiLanguage($request->lang)),
            'soc_yt'            => $this->getTranslation('soc_yt',apiLanguage($request->lang)),
            'soc_in'            => $this->getTranslation('soc_in',apiLanguage($request->lang)),
        ];
    }
}
