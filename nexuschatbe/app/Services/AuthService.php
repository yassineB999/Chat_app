<?php

namespace App\Services;

use App\Mail\SendOtpMail;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;
use Laravel\Socialite\Facades\Socialite;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class AuthService
{
    /**
     * Creates a new user and sends them an OTP.
     *
     * @param array $validatedData
     * @return User
     */
    public function registerUser(array $validatedData): User
    {
        $user = User::create([
            'name' => $validatedData['name'],
            'email' => $validatedData['email'],
            'password' => Hash::make($validatedData['password']),
        ]);

        $this->generateAndSendOtp($user);

        return $user;
    }

    /**
     * Verifies an OTP and returns the user and a new token on success.
     *
     * @param array $validatedData
     * @return array
     * @throws ValidationException
     */
     public function verifyOtp(array $validatedData): array
    {
        $user = User::where('email', $validatedData['email'])->first();

        if (!$user || $user->email_verified_at) {
            throw ValidationException::withMessages([
                'email' => 'Invalid email or this account has already been verified.',
            ]);
        }
        if (is_null($user->otp) || !Hash::check($validatedData['otp'], $user->otp) || Carbon::now()->isAfter($user->otp_expires_at)) {
            throw ValidationException::withMessages([
                'otp' => 'The OTP is invalid or has expired.',
            ]);
        }

        $user->update([
            'email_verified_at' => now(),
            'otp' => null,
            'otp_expires_at' => null,
        ]);
        
        $token = $user->createToken('auth-token')->plainTextToken;

        return [
            'user' => $user,
            'token' => $token,
        ];
    }

    /**
     * Logs a user in and returns a token.
     *
     * @param array $credentials
     * @return array
     * @throws ValidationException
     */
    public function loginUser(array $credentials): array
    {
        if (!Auth::attempt($credentials)) {
             throw ValidationException::withMessages([
                'email' => 'The provided credentials do not match our records.',
            ]);
        }
        
        /** @var User $user */
        $user = Auth::user();

        if (is_null($user->email_verified_at)) {
            Auth::logout();
            $this->generateAndSendOtp($user);

            throw ValidationException::withMessages([
                'email' => 'Your email is not verified. A new OTP has been sent to your inbox.',
            ]);
        }

        $user->tokens()->delete();
        $token = $user->createToken('auth-token')->plainTextToken;
        
        return ['user' => $user, 'token' => $token];
    }

    /**
     * Handles Google OAuth login or registration.
     *
     * @param string $accessToken
     * @return array
     * @throws ValidationException
     */
    public function handleGoogleLogin(string $accessToken): array
    {
        try {
            $googleUser = Socialite::driver('google')->stateless()->userFromToken($accessToken);

            if (!$googleUser || !$googleUser->getEmail()) {
                throw new \Exception('Invalid Google user data.');
            }

            $user = User::where('email', $googleUser->getEmail())->first();

            if ($user && is_null($user->google_id)) {
                throw ValidationException::withMessages([
                    'email' => 'An account with this email already exists. Please sign in with your password.'
                ]);
            }

            $user = User::updateOrCreate(
                ['google_id' => $googleUser->getId()],
                [
                    'name' => $googleUser->getName(),
                    'email' => $googleUser->getEmail(),
                    'password' => Hash::make(Str::random(24)),
                    'email_verified_at' => now(), // Automatically verify emails from a trusted provider like Google
                ]
            );

            $user->tokens()->delete();
            $token = $user->createToken('google_auth_token')->plainTextToken;

            return [
                'user' => $user,
                'token' => $token,
                'is_new' => $user->wasRecentlyCreated,
            ];

        } catch (ValidationException $e) {
            throw $e;
        } catch (\Exception $e) {
            Log::error('Google authentication error: ' . $e->getMessage());
            throw ValidationException::withMessages([
                'token' => 'Invalid Google access token or authentication failed.'
            ]);
        }
    }

    /**
     * Generates and sends a new OTP to a user.
     *
     * @param User $user
     * @return void
     */
    protected function generateAndSendOtp(User $user): void
    {
        $otp = random_int(100000, 999999);

        $user->update([
            'otp' => Hash::make((string) $otp), 
            'otp_expires_at' => Carbon::now()->addMinutes(10),
        ]);

        try {
            Mail::to($user->email)->send(new SendOtpMail($otp));
        } catch (\Exception $e) {
            Log::error('Failed to send OTP email: ' . $e->getMessage());
        }
    }
}