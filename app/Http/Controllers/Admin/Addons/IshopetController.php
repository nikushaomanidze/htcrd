<?php

namespace App\Http\Controllers\Admin\Addons;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class IshopetController extends Controller
{
    public function geoLocale()
    {
//        $url = 'http://ip-api.com/json/?fields=status,message,country,countryCode,region,regionName,city,zip,lat,lon,timezone,isp,org,as,query,currency';
        try {
            $url = 'http://www.geoplugin.net/json.gp';
            $response = curlRequest($url, [], 'GET');

            if (property_exists($response, 'geoplugin_status') && $response->geoplugin_status == 200) {
                $currency = [
                    'exchange_rate' => $response->geoplugin_currencyConverter,
                    'name' => $response->geoplugin_currencyCode,
                    'symbol' => $response->geoplugin_currencySymbol_UTF8,
                ];
            } else {
                $currency = [
                    'exchange_rate' => 1,
                    'name' => 'USD',
                    'symbol' => '₾',
                ];
            }
            $data = [
                'currency' => $currency
            ];
            return response()->json($data);
        } catch (\Exception $e) {
            $currency = [
                'exchange_rate' => 1,
                'name' => 'USD',
                'symbol' => '₾',
            ];
            $data = [
                'currency' => $currency
            ];
            return response()->json($data);
        }
    }

    public function updateSellerCurrency()
    {
        
    }
}
