<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class UserReferralCode extends Model
{
    use HasFactory;
    
    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = 'user_referral_codes';
    
    protected $fillable = [
        'user_id',
        'status',
        'referral_code',
        'created_at',
        'updated_at'
    ];
}
