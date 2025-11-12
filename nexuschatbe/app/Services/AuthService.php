<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Laravel\Socialite\Facades\Socialite;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

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
     public function handleGoogleLogin(string $accessToken): array
    {
        try {
            /** @var \Laravel\Socialite\Two\User $googleUser */
            $googleUser = Socialite::driver('google')->stateless()->userFromToken($accessToken);

            if (!$googleUser || !$googleUser->getEmail()) {
                throw new \Exception('Invalid Google user data.');
            }

            // Find an existing user by their email address
            $user = User::where('email', $googleUser->getEmail())->first();

            // SECURITY CHECK: If user exists with this email but NOT a google_id,
            // they signed up with a password. Block the login to prevent takeover.
            if ($user && is_null($user->google_id)) {
                throw ValidationException::withMessages([
                    'email' => 'An account with this email already exists. Please sign in with your password.'
                ]);
            }

            // Find the user by their Google ID or create them if they don't exist.
            $user = User::updateOrCreate(
                [
                    'google_id' => $googleUser->getId(),
                ],
                [
                    'name' => $googleUser->getName(),
                    'email' => $googleUser->getEmail(),
                    'password' => Hash::make(Str::random(24)), // Set a random password
                ]
            );

            // Return the user and a flag indicating if they were just created.
            return [
                'user' => $user,
                'is_new' => $user->wasRecentlyCreated,
            ];

        } catch (ValidationException $e) {
            // Re-throw the specific validation error to be caught by the controller
            throw $e;
        } catch (\Exception $e) {
            // Catch invalid tokens from Socialite or other exceptions
            Log::error('Google authentication error: ' . $e->getMessage());
            throw ValidationException::withMessages([
                'token' => 'Invalid Google access token or authentication failed.'
            ]);
        }
    }
}
