<?php

namespace App\Models;

use Cartalyst\Sentinel\Users\EloquentUser;
use Illuminate\Auth\Authenticatable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Tymon\JWTAuth\Contracts\JWTSubject;
use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Contracts\Auth\Authenticatable as ContractAuthenticatable;

class User extends EloquentUser implements JWTSubject, ContractAuthenticatable
{
    use HasApiTokens, HasFactory, Notifiable, Authenticatable;

    protected $fillable = [
        'first_name',
        'last_name',
        'user_type',
        'email',
        'card_number',
        'password',
        'images',
        'phone',
        'date_of_birth',
        'firebase_auth_id',
        'currency_code',
        'country_id',
        'lang_code',
        'is_password_set',
        'gender',
        'permissions',
        'referred_user_referral_code',
        'referral_user_id',
        'card_number'
    ];
    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at'     => 'datetime',
        'permissions'           => 'array',
        'images'                => 'array',
        'socials'               => 'array',
    ];

    protected $attributes = [
        'images'                => '[]',
        'socials'               => '[]',
        'permissions'           => '[]'
    ];

    protected $appends = ['profile_image','user_profile_image','full_name','shipping_address','billing_address','last_recharge', 'total_referral_users', 'total_active_referral_users', 'available_subscription_days', 'referral_id'];

    public $timestamps = true;
    
    public static function boot()
    {
        parent::boot();
    
        static::created(function($model)
        {
            $urc = new UserReferralCode;
            $urc->user_id = $model->id;
            $urc->status = 1;
            $urc->referral_code = rand();
            $urc->created_at = date('Y-m-d H:i:s');
            $urc->save();
            
            $model->referral_user_id = UserReferralCode::where('referral_code', $model->referred_user_referral_code)->first()->user_id ?? NULL;
            $model->save();
        });
    }
    
    public function getAvailableSubscriptionDaysAttribute(){
        $userCard = UserCard::where('user_id', $this->id)->where('status', 'Active')->first();
        $available_subscription_days = 0;
        if(!empty($userCard))
        {
            $availableDays = strtotime($userCard->end_date) - time();
            $availableDays = round($availableDays / (60 * 60 * 24));
            $available_subscription_days = $availableDays;
        }
            
        return $available_subscription_days;
    }
    
    public function getReferralIdAttribute(){
        return UserReferralCode::where('user_id', $this->id)->where('status', 1)->first()->referral_code ?? NULL;
    }
    
    public function getTotalReferralUsersAttribute(){
        return User::whereNotNull('referral_user_id')->where('referral_user_id', $this->id)->count();
    }
    
    public function getTotalActiveReferralUsersAttribute(){
        return User::whereNotNull('referral_user_id')->where('referral_user_id', $this->id)->where('card_status', 'Active')->count();
    }

    public static function byEmail($email)
    {
        return static::whereEmail($email)->first();
    }
    public function image()
    {
        return $this->belongsTo(Media::class, 'image_id');
    }

    public function role()
    {
        return $this->belongsTo(Role::class);
    }

    public function payout()
    {
        return $this->hasMany(SellerPayout::class);
    }

    public function sellerProfile()
    {
        return $this->hasOne(SellerProfile::class);
    }

    public function addresses()
    {
        return $this->hasMany(Address::class);
    }

    public function support()
    {
        return $this->hasMany(Support::class);
    }

    public function pickupHub()
    {
        return $this->belongsTo(PickupHub::class);
    }

    public function lastLogin()
    {
        return $this->hasOne(LogActivity::class)->latest()->first()->created_at;
    }

    public function reward(): \Illuminate\Database\Eloquent\Relations\HasOne
    {
        return $this->hasOne(Reward::class)->withSum('rewardDetails','reward');
    }

    public function deliveryHero()
    {
        return $this->hasOne(DeliveryHero::class);
    }

    public function wallet()
    {
        return $this->hasMany(Wallet::class);
    }

    public function compareLists(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(CompareProduct::class);
    }

    public function getProfileImageAttribute()
    {
        return @is_file_exists($this->images['image_128x128'] , $this->images['storage']) ? @get_media($this->images['image_128x128'],$this->images['storage']) : static_asset('images/default/user.jpg');
    }

    public function getUserProfileImageAttribute()
    {
        return @is_file_exists($this->images['image_20x20'] , $this->images['storage']) ? @get_media($this->images['image_20x20'],$this->images['storage']) : static_asset('images/default/user32x32.jpg');
    }

    public function getShippingAddressAttribute()
    {
        return @$this->hasOne(Address::class)->where('default_shipping',1)->first() ?? [];
    }

    public function getBillingAddressAttribute()
    {
        return @$this->hasOne(Address::class)->where('default_billing',1)->first() ?? [];
    }

    public function getFullNameAttribute()
    {
        return $this->first_name . ' ' . $this->last_name;
    }

    public function orders(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(Order::class)->where('is_deleted',0)->latest();
    }

    public function products()
    {
        return $this->hasMany(Product::class);
    }

    public function carts(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(Cart::class);
    }

    public function accounts()
    {
        return $this->hasMany(Account::class);
    }

    public function getCountOrdersAttribute(): int
    {
        return count($this->orders);
    }

    public function sellerFeaturedProducts()
    {
        return $this->hasMany(Product::class)->where('is_featured', 1)->latest();
    }

    public function getLastRechargeAttribute()
    {
        $amount = 0;
        $wallet = $this->wallet()->where('source','wallet_recharge')->where('type','income')->where('status','approved')->latest()->first();
        if ($wallet)
        {
            $amount = $wallet->amount;
        }
        return $amount;
    }

    public function sellers()
    {
        return $this->belongsToMany(SellerProfile::class)->withTimestamps();
    }

    public function wishlists()
    {
        return $this->hasMany(Wishlist::class);
    }

    public function notifications()
    {
        return $this->hasMany(Notification::class);
    }

    public function country()
    {
        return $this->belongsTo(Country::class);
    }

    public function activeSubscription(): \Illuminate\Database\Eloquent\Relations\HasOne
    {
        return $this->hasOne(SellerSubscription::class)->latest()->where('status',1)->where('expires_at','>',now());
    }

    public function getJWTIdentifier()
    {
        return $this->getKey();
    }

    public function getPhoneCodeAttribute()
    {
        $phone_code = '';
        $country = $this->country;
        $code = str_contains($country->phonecode,'+') ? $country->phonecode : '+'.$country->phonecode;

        if ($this->phone)
        {
            $phone_code_check = str_contains($this->phone,$code);
            $phone_code_check_without_plus = str_contains($this->phone,$country->phonecode);
            $phone_code .= $code;
            if ($phone_code_check)
            {
                $phone_code .= str_replace($code,'',$this->phone);
            }
            if ($phone_code_check_without_plus && !$phone_code_check)
            {
                $phone_code .= str_replace($country->phonecode,'',$this->phone);
            }
            if (!$phone_code_check && !$phone_code_check_without_plus)
            {
                $phone_code .= $this->phone;
            }
        }
        return $phone_code;
    }

    public function getJWTCustomClaims()
    {
        return [
            'id'              => $this->id,
            'name'            => $this->name,
            'email'           => $this->email,
            'created_at'      => $this->created_at,
            'updated_at'      => $this->updated_at,
        ];
    }
    
    public function cards()
    {
        return $this->hasMany(UserCard::class);
    }
}

