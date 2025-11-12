<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\AuthenticateWithGoogleRequest;
use App\Http\Requests\Api\LoginRequest;
use App\Http\Requests\Api\RegisterRequest;
use App\Services\AuthService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function __construct(protected AuthService $authService) {}

    public function register(RegisterRequest $request): JsonResponse
    {
        $token = $this->authService->registerUser($request->validated());
        return response()->json(['token' => $token], 201);
    }

    public function login(LoginRequest $request): JsonResponse
    {
        $token = $this->authService->loginUser($request->validated());

        if (!$token) {
            return response()->json(['message' => 'The provided credentials do not match our records.'], 401);
        }

        return response()->json(['user' => Auth::user(), 'token' => $token]);
    }

    public function loginWithGoogle(AuthenticateWithGoogleRequest $request): JsonResponse
    {
        try {
            // The request validated 'token' key exists.
            $result = $this->authService->handleGoogleLogin($request->validated()['token']);
            
            $user = $result['user'];
            $isNewUser = $result['is_new'];

            // Invalidate any old tokens to ensure a fresh session
            $user->tokens()->delete();

            // If the service determined this user was just created, tell the frontend
            // that onboarding is required.
            if ($isNewUser) {
                $token = $user->createToken('onboarding_token')->plainTextToken;
                
                return response()->json([
                    'message' => 'Profile incomplete. Please complete your profile.',
                    'requires_onboarding' => true,
                    'data' => [
                        'user' => $user,
                        'token' => $token,
                    ],
                ], 200);
            }

            // For existing users, generate a standard auth token
            $token = $user->createToken('google_auth_token')->plainTextToken;

            return response()->json([
                'message' => 'Google login successful.',
                'requires_onboarding' => false, // Onboarding is not required
                'data' => [
                    'user' => $user,
                    'token' => $token,
                ],
            ], 200);

        } catch (ValidationException $e) {
            return response()->json([
                'message' => 'Authentication failed.',
                'errors' => $e->errors(),
            ], 422);
        }
    }
}