<?php

namespace App\Http\Controllers\Seller\Addons;

use App\Http\Controllers\Controller;
use App\Http\Resources\AdminResource\PosOfflineMethodResource;
use App\Repositories\Interfaces\Admin\Addon\OfflineMethodInterface;
use App\Repositories\Interfaces\Admin\Addon\PackageInterface;
use App\Repositories\Interfaces\Admin\AddonInterface;
use App\Repositories\Interfaces\Admin\CurrencyInterface;
use App\Traits\PaymentTrait;
use App\Utility\AppSettingUtility;
use Brian2694\Toastr\Facades\Toastr;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class PackageController extends Controller
{
    protected $sellerPackage;

    use PaymentTrait;

    public function __construct(PackageInterface $sellerPackage)
    {
        $this->sellerPackage = $sellerPackage;
    }

    public function index()
    {
        try {
            $data = [
                'packages' => $this->sellerPackage->paginate(get_pagination('index_form_paginate'),1)
            ];
            return view('admin.seller_packages.index', $data);
        } catch (\Exception $e) {
            Toastr::error($e->getMessage());
            return redirect()->back();
        }
    }

    public function payment($id,Request $request,CurrencyInterface $currency, OfflineMethodInterface $offlineMethod,AddonInterface $addon)
    {
        $package = $this->sellerPackage->find($id);

        $ngn_exchange_rate      = 1;
        $is_paystack_activated  = settingHelper('is_paystack_activated') == 1;
        $ngn = AppSettingUtility::currencies()->where('code','NGN')->first();
        if($ngn):
            $ngn_exchange_rate     = $ngn->exchange_rate;
        else:
            $is_paystack_activated    = 0;
        endif;

        $default_currency = AppSettingUtility::currencies()->where('id',settingHelper('default_currency'))->first();

        $data = [
            'token'             => $request->token,
            'package'           => $package,
            'currency'          => $default_currency ? $default_currency->code : 'USD',
            'indian_currency'   => $currency->currencyByCode('INR'),
            'offline_methods'   => addon_is_activated('offline_payment') ? PosOfflineMethodResource::collection($offlineMethod->activeMethods()) : [],
            'jazz_data'         => $this->jazzCashPayment(),
            'jazz_url'          => config('jazz_cash.TRANSACTION_POST_URL'),
            'addons'            => $addon->activePlugin(),
            'trx_id'            => Str::random(),
            'code'              => '',
            'amount'            => $package->price,
            'ngn_exchange_rate' => $ngn_exchange_rate,
            'paystack_activated'=> $is_paystack_activated,
            'fw_activated'      => settingHelper('is_flutterwave_activated') == 1,
            'default_assets'    => [
                'preloader'     => static_asset('images/default/preloader.gif'),
                'review_image'  => static_asset('images/others/env.svg'),
            ]
        ];
        return view('seller.packages.payment', $data);
    }
}
