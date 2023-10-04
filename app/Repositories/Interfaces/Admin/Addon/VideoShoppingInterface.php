<?php

namespace App\Repositories\Interfaces\Admin\Addon;

interface VideoShoppingInterface
{
    public function get($id);

    public function all();

    public function getByLang($id, $lang);

    public function store($request);

    public function update($request);

    public function paginate($limit,$request,$for);

    public function statusChange($request);

    public function shopBySlug($slug);

    public function shopBySlugApi($slug);

}
