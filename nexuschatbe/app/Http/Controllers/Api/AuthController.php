<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\AuthenticateWithGoogleRequest;
use App\Http\Requests\Api\LoginRequest;
use App\Http\Requests\Api\RegisterRequest;
use App\Http\Requests\VerifyOtpRequest;
use App\Services\AuthService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function __construct(protected AuthService $authService) {}

    public function register(RegisterRequest $request): JsonResponse
    {
        $user = $this->authService->registerUser($request->validated());

        return response()->json([
            'message' => 'Registration successful. An OTP has been sent to your email for verification.',
            'data' => [
                'email' => $user->email,
            ]
        ], 201);
    }
    

    public function verifyOtp(VerifyOtpRequest $request): JsonResponse
    {
        try {
            $result = $this->authService->verifyOtp($request->validated());

            return response()->json([
                'message' => 'Email verified successfully. You are now logged in.',
                'data' => $result,
            ]);
        } catch (ValidationException $e) {
            return response()->json([
                'message' => 'Verification failed.',
                'errors' => $e->errors(),
            ], 422);
        }
    }


    public function login(LoginRequest $request): JsonResponse
    {
        try {
            $result = $this->authService->loginUser($request->validated());

            return response()->json([
                'message' => 'Login successful.',
                'data' => $result, 
            ]);
        } catch (ValidationException $e) {
            return response()->json([
                'message' => 'Login failed.',
                'errors' => $e->errors(),
            ], 422); 
        }
    }


    public function loginWithGoogle(AuthenticateWithGoogleRequest $request): JsonResponse
    {
        try {
            $result = $this->authService->handleGoogleLogin($request->validated()['token']);
            
            $message = $result['is_new'] 
                ? 'Google registration successful. You are now logged in.' 
                : 'Google login successful.';

            return response()->json([
                'message' => $message,
                'data' => [
                    'user' => $result['user'],
                    'token' => $result['token'],
                ],
            ]);

        } catch (ValidationException $e) {
            return response()->json([
                'message' => 'Authentication failed.',
                'errors' => $e->errors(),
            ], 422);
        }
    }
    
    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();
        
        return response()->json(['message' => 'Successfully logged out.']);
    }
}