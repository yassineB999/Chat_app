<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\LoginRequest;
use App\Http\Requests\Api\RegisterRequest;
use App\Http\Requests\Api\GoogleLoginRequest;
use App\Services\AuthService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

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

    public function handleGoogleLogin(GoogleLoginRequest $request): JsonResponse
    {
        // The GoogleLoginRequest already validated that 'access_token' is present
        $accessToken = $request->validated()['access_token'];

        // Delegate the core logic to the AuthService
        $result = $this->authService->handleGoogleLoginWithToken($accessToken);

        // If the service returns null, it means the token was invalid or an error occurred
        if (!$result) {
            return response()->json([
                'message' => 'Invalid or expired Google token.'
            ], 401);
        }

        // On success, return the user and token data provided by the service
        return response()->json($result);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['message' => 'Successfully logged out']);
    }
}

