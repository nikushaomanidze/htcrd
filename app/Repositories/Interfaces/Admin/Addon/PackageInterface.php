<?php

namespace App\Repositories\Interfaces\Admin\Addon;

interface PackageInterface
{
    public function all();

    public function paginate($limit,$status=null);

    public function find($id);

    public function store($data);

    public function update($data,$id);

    public function destroy($id);
}
