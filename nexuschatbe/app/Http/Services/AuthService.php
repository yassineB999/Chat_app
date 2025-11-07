<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Laravel\Socialite\Facades\Socialite;
use Illuminate\Support\Str;

class AuthService
{
    public function registerUser(array $validatedData): string
    {
        $user = User::create([
            'name' => $validatedData['name'],
            'email' => $validatedData['email'],
            'password' => Hash::make($validatedData['password']),
        ]);

        return $user->createToken('auth-token')->plainTextToken;
    }

    public function loginUser(array $credentials): ?string
    {
        if (!Auth::attempt($credentials)) {
            return null;
        }

        /** @var User $user */
        $user = Auth::user();
        $user->tokens()->delete();

        return $user->createToken('auth-token')->plainTextToken;
    }
    public function handleGoogleLoginWithToken(string $accessToken): ?array
    {
        try {
            // 1. Get the user details from Google using the provided token
            $googleUser = Socialite::driver('google')->stateless()->userFromToken($accessToken);

            // 2. Find a user in your database by their email or create a new one
            $user = User::updateOrCreate(
                [
                    'email' => $googleUser->getEmail(), // Use email as the key to find the user
                ],
                [
                    'name' => $googleUser->getName(),
                    'google_id' => $googleUser->getId(),
                    'password' => Hash::make(Str::random(24)),
                ]
            );

            // 3. Invalidate any old tokens and create a new one for the user
            $user->tokens()->delete();
            $token = $user->createToken('auth-token-google')->plainTextToken;

            return [
                'user' => $user,
                'token' => $token,
            ];

        } catch (\Exception $e) {
            Log::error('Google Token Login Failed: ' . $e->getMessage());
            return null;
        }
    }
}
