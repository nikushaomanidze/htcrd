<?php

namespace App\Repositories\Interfaces\Admin\Addon;

interface SellerSubscriptionInterface
{
    public function all();

    public function paginate($limit, $request);

    public function get($id);

    public function store($data);

    public function update($data,$id);

    public function destroy($id);
}
