@extends('admin.partials.master')
@section('title')
    {{ __('Order Invoice') }}
@endsection
@section('order_active')
    active
@endsection
@section('orders')
    active
@endsection
@section('main-content')

    <section class="section">
        <div class="section-body">
            <div class="invoice">
                <div class="row">
                    <div class="col-lg-12">
                        <div class="card-header-form float-right form-inline">
                            @if(!$order->pickupHub)
                                <form action="{{ route('order.assign.delivery.hero') }}" method="POST" class=""
                                      id="sorting"
                                      data-for="assign-hero">
                                    @csrf
                                    <input type="hidden" name="id" value="{{ $order->id }}">
                                    <div class="form-group">
                                        <select
                                                class="form-control selectric sorting {{ $order->delivery_status == 'delivered' || $order->delivery_status == 'canceled' ? 'cursor-not-allowed' : '' }}"
                                                {{ $order->delivery_status == 'delivered' || $order->delivery_status == 'canceled' ? 'disabled' : '' }} data-empty="{{ __('Please select Delivery Man') }}"
                                                name="delivery_hero">
                                            <option value="">{{ __('Assign Delivery Man') }}</option>
                                            @foreach($delivery_heroes as $key => $delivery_hero)
                                                <option
                                                        {{ $delivery_hero->deliveryHero->id == $order->delivery_hero_id ? "selected" : "" }} value="{{ $delivery_hero->deliveryHero->id }}">{{ $delivery_hero->first_name. ' '.$delivery_hero->last_name  }}</option>
                                            @endforeach
                                        </select>
                                    </div>
                                </form>
                            @endif
                            @if($order->payment_type != 'offline_method')
                                <form action="{{ route('order.payment.status.change') }}" method="POST"
                                      id="onChangeFormSubmit2">
                                    @csrf

                                    <input type="hidden" name="id" value="{{ $order->id }}">
                                    <div class="form-group">
                                        <select
                                                class="form-control selectric {{ $order->delivery_status == "canceled" || $order->delivery_status == "delivered"  ? 'cursor-not-allowed' : '' }}"
                                                id="payment_status"
                                                data-title="{{__('Account Deposit')}}"
                                                data-toggle="modal" data-target="#common-modal"
                                                class="dropdown-item has-icon modal-menu"
                                                {{ $order->delivery_status == "canceled" || $order->delivery_status == "delivered"? 'disabled' : '' }} name="payment_status">
                                            @if($order->payment_status != "refunded_to_wallet" && $order->delivery_status != 'delivered ')
                                                <option
                                                        {{ $order->payment_status == "unpaid" ? "selected" : "" }} value="unpaid">{{ __('Unpaid') }}
                                                </option>
                                                <option
                                                        {{ $order->payment_status == "paid" ? "selected" : "" }} value="paid">{{ __('Paid') }}
                                                </option>
                                            @endif
                                            @if($order->payment_status == "refunded_to_wallet" || $order->payment_type == 'cash_on_delivery' || $order->pickupHub)
                                                <option
                                                        {{ $order->payment_status == "paid" ? "selected" : "" }} value="paid">{{ __('Paid') }}</option>
                                            @endif
                                            @if($order->payment_status == "refunded_to_wallet")
                                                <option
                                                        {{ $order->payment_status == "refunded_to_wallet" ? "selected" : "" }} value="refunded_to_wallet">{{ __('Refunded to wallet') }}</option>
                                            @endif
                                        </select>
                                    </div>
                                </form>
                            @else
                                <div>
                                    <p class="mb-0 mr-3"><strong>{{__('Offline Payment')}}</strong></p>
                                    <p class="mb-0 mr-3"><strong> {{ __('status') }}
                                            : {{ __($order->payment_status) }} </strong></p>
                                </div>
                            @endif
                            <form action="{{ route('order.delivery.status.change') }}" method="POST" class=""
                                  id="onChangeFormSubmit">
                                @csrf
                                <input type="hidden" name="id" value="{{ $order->id }}">
                                <div class="form-group">
                                    <select class="form-control selectric onChangeFormSubmit {{ $order->delivery_status == "delivered" ? 'cursor-not-allowed' : '' }}"
                                            name="delivery_status" {{ $order->delivery_status == "delivered" ? 'disabled' : '' }}>
                                        <option
                                                {{ $order->delivery_status == "pending" ? "selected" : "" }} value="pending">{{ __('Pending') }}</option>
                                        <option
                                                {{ $order->delivery_status == "confirmed" ? "selected" : "" }} value="confirmed">{{ __('Confirmed') }}</option>
                                        <option
                                                {{ $order->delivery_status == "picked_up" ? "selected" : "" }} value="picked_up">{{ __('Picked Up') }}</option>
                                        <option
                                                {{ $order->delivery_status == "on_the_way" ? "selected" : "" }} value="on_the_way">{{ __('On The Way') }}</option>
                                        @if($order->delivery_status != 'delivered')
                                            <option
                                                    {{ $order->delivery_status == "canceled" ? "selected" : "" }} value="canceled">{{__('Canceled')}}</option>
                                        @endif
                                        @if($order->payment_status == 'paid' || $order->delivery_status == "delivered")
                                            <option
                                                    {{ $order->delivery_status == "delivered" ? "selected" : "" }} value="delivered">{{__('Delivered')}}</option>
                                        @endif
                                    </select>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
                <div class="invoice-print">
                    <div class="row">
                        <div class="col-lg-12 pt-2">
                            <div class="invoice-title">
                                @php
                                    $logo = settingHelper('admin_dark_logo')
                                @endphp
                                <img
                                        src="{{($logo != [] && is_file_exists($logo['image_100x38'])) ? static_asset($logo['image_100x38']) : static_asset('images/default/dark-logo.png') }}"
                                        alt="logo" width="100">
                                <h2>{{ __('Invoice') }}</h2>
                                <div class="invoice-number">{{__('Order')}} #{{ $order->code }}</div>
                            </div>
                            <hr>
                            

                            <div class="row">


                                <div class="col-md-6 col-12 col-sm-6 text-md-right">
                                    <address>
                                        <strong>{{__('Order Date')}}:</strong><br>
                                        {{ \Carbon\Carbon::parse($order->date)->format('d F, Y h:i:s A') }}<br><br>
                                    </address>
                                </div>
                            </div>

                        </div>
                    </div>

                    <div class="row mt-4">
                        <div class="col-md-12">
                            <div class="section-title">{{__('Order Summary')}}</div>
                            <div class="table-responsive">
                                <table class="table table-striped table-hover table-md">
                                    <tr>
                                        <th width="5%">#</th>
                                        <th width="40%">{{__('Product')}}</th>
                                        <th class="text-center" width="15%">{{__('Unit Price')}}</th>
                                        <th class="text-center" width="15%">{{__('Quantity')}}</th>
                                        <th class="text-center" width="15%">{{__('Additional Product Id')}}</th>
                                        
                                        


                                        <th class="text-right" width="25%">{{__('Totals')}}</th>
                                    </tr>
                                    
                                    @foreach ($order->orderDetails as $key => $orderDetail)
                                        @php
                                            $product = $orderDetail->product;

                                            $sub_total = ($orderDetail->price * $orderDetail->quantity);
                                        @endphp
                                        <tr>
                                            <td>{{ $key+1 }}</td>
                                            <td>
                                                <div class="d-flex">
                                                    @if($product)
                                                        <div class="text-left">
                                                            @if ($product->thumbnail != [] && is_file_exists($product->thumbnail['image_40x40'], $product->thumbnail['storage']))
                                                                <img
                                                                        src="{{ get_media($product->thumbnail['image_40x40'], $product->thumbnail['storage']) }}"
                                                                        alt="{{ $product->name }}"
                                                                        class="mr-3 rounded">
                                                            @else
                                                                <img
                                                                        src="{{ static_asset('images/default/default-image-40x40.png') }}"
                                                                        alt="{{ $product->name }}"
                                                                        class="mr-3 rounded">
                                                            @endif
                                                        </div>
                                                        <div class="ml-1">
                                                            @if(isAppMode())
                                                                {{ $product->getTranslation('name', \App::getLocale()) }}
                                                                @if($orderDetail->variation != null)
                                                                    ({{ $orderDetail->variation }})
                                                                @endif
                                                            @else
                                                                <a href="{{ route('product-details',$product->slug) }}" target="_blank">
                                                                    {{ $product->getTranslation('name', \App::getLocale()) }}
                                                                    @if($orderDetail->variation != null)
                                                                        ({{ $orderDetail->variation }})
                                                                    @endif
                                                                </a>
                                                            @endif
                                                        </div>
                                                    @else
                                                        <div class="text-left">
                                                            <img
                                                                    src="{{ static_asset('images/default/default-image-40x40.png') }}"
                                                                    alt="N/A"
                                                                    class="mr-3 rounded">
                                                        </div>
                                                        <div class="ml-1">
                                                            N/A
                                                        </div>
                                                    @endif
                                                </div>
                                            </td>
                                            <td class="text-center">{{ get_price($orderDetail->price,user_curr()) }}</td>
                                            <td class="text-center">
                                                {{ $orderDetail->quantity }}
                                            </td>
                                            <td class="text-center txt_nowrap">
                                                <a href="https://tapp.ge/hotcard/admin/edit-product/{{ $orderDetail->additional_product_id }}">{{ $orderDetail->additional_product_id }}</a>
                                            </td>
                                           
                                            

                                            
                                            <td class="text-right txt_nowrap">{{ get_price($sub_total,user_curr()) }}</td>
                                        </tr>
                                    @endforeach


                                </table>
                            </div>
                            <div class="row mt-4">
                                <div class="col-lg-8">
                                </div>
                                @php
                                    $total_payable = 0;
                                @endphp
                                <div class="col-lg-4 text-right">
                                    <table class="table-borderless text-right">
                                        <tr>
                                            <td class="invoice-detail-name"> {{ __('Sub Total') }}:</td>
                                            <td class="invoice-detail-value">{{ get_price($order->sub_total,user_curr()) }}</td>
                                            @php
                                                $total_payable += $order->sub_total;
                                            @endphp
                                        </tr>

                                       
                                        
                                        
                                        <tr>
                                            <td class="invoice-detail-name"></td>
                                            <td>-------------</td>
                                        </tr>
                                        <tr>
                                            <td class="invoice-detail-name"> {{ __('Net Payable') }}:</td>
                                            <td class="invoice-detail-value">{{ get_price($total_payable,user_curr()) }}</td>
                                        </tr>

                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <hr>
                <div class="text-md-right">
                    <div class="float-lg-left mb-lg-0 mb-3">
                    </div>
                    <a target="_blank" href="{{ route('order.invoice.download',$order->id) }}"
                       class="btn btn-warning btn-icon icon-left"><i class="bx bx-download"></i> {{__('PDF')}}</a>
                    <a href="#" onclick="window.print();return false;" class="btn btn-primary btn-icon icon-left"><i
                                class="bx bx-printer"></i> {{__('Print')}}</a>
                </div>
                @if(count($order->deliveryHistories) > 0 || count($order->paymentHistories) > 0)
                    <div class="row">
                        @if(count($order->deliveryHistories) > 0)
                            <div class="col-md-6 col-6 col-sm-6">
                                <h2 class="section-title">{{ __('Order Histories') }}</h2>
                                <div class="row">
                                    <div class="col-12">
                                        <div class="activities">
                                            @foreach($order->deliveryHistories as $key => $history)
                                                <div class="activity">
                                                    <div class="activity-icon text-white

                                        @if($history->event == 'order_canceled_event')
                                                bg-danger shadow-danger
@elseif($history->event == 'order_delivered_event')
                                                bg-success shadow-success
@elseif($history->event == 'order_on_the_way_event')
                                                bg-warning shadow-warning
@else
                                                bg-primary shadow-primary
@endif">

                                                        @if($history->event == 'delivery_hero_assigned' || $history->event == 'delivery_hero_changed')
                                                            <i class="bx bx-purchase-tag"></i>
                                                        @elseif($history->event == 'order_canceled_event')
                                                            <i class="bx bx-x"></i>
                                                        @elseif($history->event == 'order_on_the_way_event')
                                                            <i class="bx bxs-truck"></i>
                                                        @elseif($history->event == 'order_canceled_event')
                                                            <i class="bx bx-x"></i>
                                                        @elseif($history->event == 'order_delivered_event')
                                                            <i class="bx bx-check"></i>
                                                        @else
                                                            <i class="bx bx-check"></i>
                                                        @endif
                                                    </div>
                                                    <div class="activity-detail">
                                                        <div class="mb-2">
                                            <span class="text-job text-primary">
                                                {{ \Carbon\Carbon::parse($history->created_at)->diffForHumans() }}
                                            </span>
                                                        </div>
                                                        <p>{{ __($history->event) }}</p>
                                                        @if(($history->event == 'delivery_hero_assigned' || $history->event == 'order_delivered_event' || $history->event == 'delivered_man_changed') && $history->deliveryHero)
                                                            <p>
                                                                {{ __('Delivery Man').': '.$history->deliveryHero->user->first_name.' '.$history->deliveryHero->last_name }}
                                                            </p>
                                                            <p>
                                                                {{ __('By').': '.@$history->user->first_name.' '.@$history->user->last_name }}
                                                            </p>
                                                        @else
                                                            <p>
                                                                {{ __('By').': '.@$history->user->first_name.' '.@$history->user->last_name }}
                                                            </p>
                                                        @endif
                                                    </div>
                                                </div>
                                            @endforeach
                                        </div>
                                    </div>
                                </div>
                            </div>
                        @endif
                        @if(count($order->paymentHistories) > 0)
                            <div class="col-md-6 col-6 col-sm-6">
                                <h2 class="section-title">{{ __('Payment Histories') }}</h2>
                                <div class="row">
                                    <div class="col-12">
                                        <div class="activities">
                                            @foreach($order->paymentHistories as $key => $history)
                                                <div class="activity">
                                                    <div class="activity-icon text-white

                                                @if($history->event == 'order_payment_unpaid_event')
                                                bg-danger shadow-danger
@elseif($history->event == 'order_payment_paid_event')
                                                bg-success shadow-success
@elseif($history->event == 'order_payment_refunded_to_wallet_event')
                                                bg-warning shadow-warning
@else
                                                bg-primary shadow-primary
@endif">
                                                        @if($history->event == 'order_payment_unpaid_event')
                                                            <i class="bx bx-x"></i>
                                                        @elseif($history->event == 'order_payment_paid_event')
                                                            <i class="bx bx-check"></i>
                                                        @elseif($history->event == 'order_payment_refunded_to_wallet_event')
                                                            <i class="bx bx-wallet-alt"></i>
                                                        @else
                                                            <i class="bx bx-check"></i>
                                                        @endif
                                                    </div>
                                                    <div class="activity-detail">
                                                        <div class="mb-2">
                                            <span class="text-job text-primary">
                                                {{ \Carbon\Carbon::parse($history->created_at)->diffForHumans() }}
                                            </span>
                                                        </div>
                                                        <p>{{ __($history->event) }}</p>
                                                        <p>{{ __($history->remarks) }}</p>
                                                        <p>
                                                            {{ __('By').': '.@$history->user->first_name.' '.@$history->user->last_name }}
                                                        </p>
                                                    </div>
                                                </div>
                                            @endforeach
                                        </div>
                                    </div>
                                </div>
                            </div>
                        @endif
                    </div>
                @endif
            </div>
        </div>
    </section>

@endsection
@section('modal')
    <div class="modal fade" id="payment_modal" tabindex="-1" role="dialog" aria-labelledby="exampleModalCenterTitle"
         aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered" role="document">
            <div class="modal-content p-0 b-0">
                <div class="panel panel-color panel-primary">
                    <div class="modal-header">
                        <h5 class="modal-title" id="common-modal-title">{{ __('Payment Status Update') }}</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <i class="bx bx-x"></i>
                        </button>
                    </div>
                </div>
                <form action="{{ route('order.payment.status.change') }}" method="post">
                    @csrf
                    <div class="modal-body modal-padding-bottom modal-body-overflow-unset">

                        <input type="hidden" name="id" value="{{ $order->id }}">
                        <input type="hidden" name="payment_status" value="paid">
                        <div class="form-group align-items-center">
                            <label for="order_no" class="form-control-label">{{ __('Order No') }}</label>
                            <input type="text" id="order_no" value="{{ $order->code }}" name="order_no"
                                   class="form-control" readonly="" disabled="">
                        </div>
                        <div class="form-group align-items-center">
                            <label for="total_payable" class="form-control-label"></label>
                            <input type="text" id="total_payable" value="{{ get_price($order->total_payable,user_curr()) }}"
                                   class="form-control" readonly="" disabled="">
                        </div>
                        <div class="form-group">
                            <label for="payment_type">{{ __('Paid by') }}</label>
                            <select class="form-control selectric" name="payment_type" id="payment_type">
                                <option value="cash">{{ __('Cash') }}</option>
                                <option value="wallet">{{ __('Wallet') }}</option>
                            </select>
                        </div>
                        <div class="form-group" id="modal_payment_type">
                            <div class="custom-control custom-checkbox">
                                <input type="checkbox" name="paid_to_delivery_man" class="custom-control-input"
                                       tabindex="3" id="paid-to-delivery-man">
                                <label class="custom-control-label"
                                       for="paid-to-delivery-man">{{ __('Paid to delivery man') }}</label>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer modal-padding-bottom">
                        <button type="submit" class="btn btn-outline-primary">{{ __('Submit') }}</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
@endsection
