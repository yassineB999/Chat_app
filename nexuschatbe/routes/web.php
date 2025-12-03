<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return response()->json([
        'message' => 'NexusChat API is running',
        'status' => 'active',
        'version' => '1.0.0'
    ]);
});
