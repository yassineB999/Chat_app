<?php

use App\Http\Controllers\Api\AuthController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/auth/google/callback', [AuthController::class, 'handleGoogleCallback'])->name('auth.google.callback');


Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');
