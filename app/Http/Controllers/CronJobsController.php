<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\UserReferralCode;
use App\Models\UserCard;
use Illuminate\Http\Request;

class CronJobsController extends Controller
{
    public function user_cards_status_check()
    {
        $date = date('Y-m-d H:i:s');
        $cards = UserCard::where('status', 'Active')->get();
        
        foreach($cards as $card)
        {
            if($date > $card->end_date)
            {
                $card->status = 'Inactive';
                $card->update();
                
                $card->user->card_status = 'Inactive';
                $card->user->update();
            }
        }
        
        
        $urcs = UserReferralCode::selectRaw('id, status, user_id, created_at, DATE_ADD(created_at, INTERVAL 1 DAY) AS  later_date')->where('status', 1)->whereRaw("DATE_ADD(created_at, INTERVAL 1 DAY) < '{$date}'")->get();
        
        foreach($urcs as $urc)
        {
            $urc->status = 0;
            $urc->update();
            
            $newUrc = new UserReferralCode;
            $newUrc->user_id = $urc->user_id;
            $newUrc->status = 1;
            $newUrc->referral_code = rand();
            $newUrc->created_at = date('Y-m-d H:i:s');
            $newUrc->save();
        }
    }
}