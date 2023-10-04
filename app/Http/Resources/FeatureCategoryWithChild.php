<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class FeatureCategoryWithChild extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return array|\Illuminate\Contracts\Support\Arrayable|\JsonSerializable
     */
    public function toArray($request)
    {

        return [
            'id'                => $this->id,
            'icon'              => nullCheck($this->icon),
            'title'             => $this->getTranslation('title',languageCheck()),
            'image'             => $this->image,
            'latlong'           => $this->getTranslation('meta_description',apiLanguage($request->lang)),
            'category_filter'   => $this->getTranslation('category_filter',apiLanguage($request->lang)),
            'number'            => $this->getTranslation('number',apiLanguage($request->lang)),
            'soc_fb'            => $this->getTranslation('soc_fb',apiLanguage($request->lang)),
            'soc_yt'            => $this->getTranslation('soc_yt',apiLanguage($request->lang)),
            'soc_in'            => $this->getTranslation('soc_in',apiLanguage($request->lang)),
        ];
    }
}
