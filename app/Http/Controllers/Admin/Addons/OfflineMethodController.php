<?php

namespace App\Http\Controllers\Admin\Addons;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\OfflineMethodRequest;
use App\Repositories\Interfaces\Admin\Addon\OfflineMethodInterface;
use App\Repositories\Interfaces\Admin\LanguageInterface;
use Brian2694\Toastr\Facades\Toastr;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class OfflineMethodController extends Controller
{
    protected $methods;
    protected $languages;

    public function __construct(OfflineMethodInterface $methods, LanguageInterface $languages)
    {
        $this->methods  = $methods;
        $this->languages    = $languages;
    }

    public function index(Request $request)
    {
        $methods = $this->methods->paginate($request, get_yrsetting('index_form_paginate'));
        return view('admin.settings.offline-payment.index', compact('methods'));
    }

    public function create(Request $request)
    {
        $languages  = $this->languages->all()->orderBy('id', 'asc')->get();
        return view('admin.settings.offline-payment.form', compact('languages'));
    }

    public function store(OfflineMethodRequest $request)
    {
        if (isDemoServer()):
            Toastr::info(__('This function is disabled in demo server.'));
            return redirect()->back();
        endif;

        DB::beginTransaction();
        try {
            $this->methods->store($request);
            Toastr::success(__('Method Created Successfully'));
            DB::commit();
            return redirect()->route('offline.payment.methods');
        } catch (\Exception $e) {
            DB::rollBack();
            Toastr::error($e->getMessage());
            return back();
        }
    }

    public function edit($id, Request $request){
        try {
            $lang       = $request->lang != '' ? $request->lang : \App::getLocale();
            if ($method_language  = $this->methods->getByLang($id, $lang)) :
                $languages  = $this->languages->all()->orderBy('id', 'asc')->get();
                $r          = $request->r != ''? $request->r : $request->server('HTTP_REFERER');

                return view('admin.settings.offline-payment.form', compact('method_language', 'r','languages','lang'));
            else:
                Toastr::error(__('Not found'));
                return back()->withInput();
            endif;
        } catch (\Exception $e){
            Toastr::error(__($e->getMessage()));
            return back()->withInput();
        }
    }
    public function update(OfflineMethodRequest $request){
        if (isDemoServer()):
            Toastr::info(__('This function is disabled in demo server.'));
            return redirect()->back();
        endif;

        DB::beginTransaction();
        try {
            $this->methods->update($request);
            Toastr::success(__('Updated Successfully'));
            DB::commit();
            return redirect($request->r);

        } catch (\Exception $e){
            DB::rollBack();
            Toastr::error($e->getMessage());
            return back()->withInput();
        }
    }

    public function statusChane(Request $request)
    {
        if (isDemoServer()):
            $response['message'] = __('This function is disabled in demo server.');
            $response['title'] = __('Ops..!');
            $response['status'] = 'error';
            return response()->json($response);
        endif;

        DB::beginTransaction();
        try {
            $this->methods->statusChange($request['data']);
            $response['message'] = __('Updated Successfully');
            $response['title'] = __('Success');
            $response['status'] = 'success';
            DB::commit();
            return response()->json($response);

        } catch (\Exception $e) {
            DB::rollBack();
            Toastr::error($e->getMessage());
            return back()->withInput();
        }
    }
}
