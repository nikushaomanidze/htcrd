@php
    $user = App\Models\User::find($otherLinks[0]);
    
    $url = "http://tapp.ge/hotcard/api/v100/user/referral_users_lists/{{ $user->referral_id }}";

    $curl = curl_init();
    
    curl_setopt_array($curl, array(
      CURLOPT_URL => $url,
      CURLOPT_RETURNTRANSFER => true,
      CURLOPT_ENCODING => "",
      CURLOPT_MAXREDIRS => 10,
      CURLOPT_TIMEOUT => 0,
      CURLOPT_FOLLOWLOCATION => true,
      CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
      CURLOPT_CUSTOMREQUEST => "POST",
    ));
    
    $response = curl_exec($curl);
    
    curl_close($curl);




@endphp
<div>
    <div class="modal-body modal-padding-bottom modal-body-overflow-unset">
        <div class="card-body">
            <div class="user-item">
                <div>
                    @if(!blank($user->images))
                        <img src="{{ get_media($user->images['image_128x128'],$user->images['storage']) }}" alt="{{ $user->first_name }}"
                             class="imagecheck-image article-image">
                    @else
                        <img src="{{ static_asset('images/default/user.jpg') }}" alt="{{ $user->first_name }}"
                             class="imagecheck-image article-image">
                    @endif
                </div>
                <div class="user-details">
                    <div class="user-name">{{ $user->first_name }} {{ $user->last_name }}</div>
                </div>
            </div>
        </div>

        <div class="table-responsive">
            <h6>{{ __('Basic Information') }}</h6>
            <table class="table table-striped table-md">
                <tbody>
                <tr>
                    <td>{{ __('Phone Number:') }}</td>
                    <td>{{ $user->phone }}</td>
                </tr>
                <tr>
                    <td>{{ __('Email :') }}</td>
                    <td>{{ $user->email }}</td>
                </tr>
                <tr>
                    <td>{{ __('Total Saved :') }}</td>
                    <td>{{ get_price($user->balance) }}</td>
                </tr>
                <tr>
                    <td>{{ __('Gender :') }}</td>
                    <td>{{ $user->gender }}</td>
                </tr>
                <tr>
                    <td>{{ __('Date Of Birth :') }}</td>
                    <td>{{ $user->date_of_birth }}</td>
                </tr>
                <tr>
                    <td>{{ __('Card Number :') }}</td>
                    <td>{{ $user->card_number ?: "empty" }}</td>
                </tr>
                <tr>
                    <td>{{ __('Register On:') }}</td>
                    <td>{{ \Carbon\Carbon::parse($user->created_at)->diffForHumans() }}</td>
                </tr>
                <tr>
                    <td>{{ __('Last Login:') }}</td>
                    <td>{{ $user->last_login != null ? \Carbon\Carbon::parse($user->last_login)->diffForHumans() : __('Not Login Yet') }} </td>
                </tr>
                </tbody>
            </table>
        </div>
        <div class="table-responsive">
            <h6>{{ __('Invited Members') }}</h6>
            <table class="table table-striped table-md">
                <tbody>
                <tr>
                    <td>{{ __('Name:') }}</td>
                    <td>{{ $user->referral_id }}</td>
                </tr>
                </tbody>
            </table>
        </div>
    </div>
</div>
