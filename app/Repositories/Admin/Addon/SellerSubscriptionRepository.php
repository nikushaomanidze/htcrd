<?php

namespace App\Repositories\Admin\Addon;

use App\Models\SellerSubscription;
use App\Traits\ImageTrait;
use App\Traits\PaymentTrait;
use Illuminate\Support\Facades\DB;
use App\Repositories\Interfaces\Admin\Addon\SellerSubscriptionInterface;

class SellerSubscriptionRepository implements SellerSubscriptionInterface
{
    use ImageTrait, PaymentTrait;

    public function all()
    {
        return SellerSubscription::latest();
    }

    public function paginate($limit, $request, $for = '')
    {
        return $this->all()
            ->when(authUser()->user_type != 'admin' || authUser()->user_type == 'staff', function ($q){
                $q->where('user_id', authId());
            })
            ->when($request->q != null, function ($q) use ($request){
                $q->where('price', 'LIKE', '%'.$request->q.'%');
                $q->orWhere('type', 'LIKE', '%'.$request->q.'%');
                $q->orWhere('title', 'LIKE', '%'.$request->q.'%');
                $q->orWhere('transaction_id', 'LIKE', '%'.$request->q.'%');

                $q->orWhereHas('user', function ($qu) use ($request) {
                    $qu->where('email', 'LIKE', '%' . $request->q . '%');
                    $qu->orWhere(DB::raw("CONCAT(`first_name`, ' ', `last_name`)"), 'LIKE', "%" . $request->q . "%");
                });
            })
            ->when($request->s != null, function ($query) use ($request){
                $query->where('status', $request->s);
            })->paginate($limit);
    }

    public function get($id)
    {
        return SellerSubscription::find($id);
    }

    public function store($data)
    {
        return SellerSubscription::create($data);
    }

    public function update($data,$id)
    {
        $subscription = SellerSubscription::find($data);
        $subscription->update($data);
        return $subscription;
    }

    public function destroy($id): int
    {
        return SellerSubscription::destroy($id);
    }
}
