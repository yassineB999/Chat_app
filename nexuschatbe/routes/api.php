<?php

use App\Http\Controllers\Api\AuthController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

use App\Http\Controllers\ChatController;
use Illuminate\Support\Facades\Broadcast;

Broadcast::routes(['middleware' => ['auth:sanctum']]);

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/auth/google', [AuthController::class, 'googleLogin']);
Route::post('/verify-otp', [AuthController::class, 'verifyOtp']);


Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    // Chat Routes
    Route::get('/users/search', [ChatController::class, 'searchUsers']);
    Route::post('/chat/provide', [ChatController::class, 'provide']);
    Route::post('/chat/rooms/{roomId}/messages', [ChatController::class, 'send']);
    Route::get('/chat/rooms', [ChatController::class, 'getChatRooms']);
    Route::get('/chat/rooms/{roomId}/messages', [ChatController::class, 'getMessages']);
});
