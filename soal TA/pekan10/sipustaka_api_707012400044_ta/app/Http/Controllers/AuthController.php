<?php

namespace App\Http\Controllers;

use App\Http\Requests\RegisterRequest;
use App\Http\Requests\LoginRequest;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    // Registrasi pengguna
    public function register(RegisterRequest $request)
    {
        $data = $request->validated();

        if (User::where('email', $data['email'])->exists()) {
            return response()->json([
                'message' => 'Email sudah terdaftar'
            ], 409);
        }

        $user = User::create([
            'name' => $data['name'],
            'email' => $data['email'],
            'password' => Hash::make($data['password']),
        ]);

        return response()->json([
            'message' => 'Registrasi berhasil',
            'user' => $user->only(['id', 'name', 'email'])
        ], 201);
    }

    // Login dan membuat token Sanctum
    public function login(LoginRequest $request)
    {
        $data = $request->validated();

        $user = User::where('email', $data['email'])->first();

        if (!$user ||
            !Hash::check($data['password'], $user->password)) {
            return response()->json([
                'message' => 'Email atau password salah'
            ], 401);
        }

        $token = $user->createToken('sipustaka-token')
                      ->plainTextToken;

        return response()->json([
            'message' => 'Login berhasil',
            'token_type' => 'Bearer',
            'access_token' => $token,
            'user' => $user->only(['id', 'name', 'email'])
        ]);
    }

    // Melihat profil pengguna
    public function me(Request $request)
    {
        return response()->json(
            $request->user()->only(['id', 'name', 'email'])
        );
    }

    // Menghapus token login saat ini
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Logout berhasil'
        ]);
    }
}