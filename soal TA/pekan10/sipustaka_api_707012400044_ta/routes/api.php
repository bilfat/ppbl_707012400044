<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\BookController;
use App\Http\Controllers\LoanController;

// Endpoint publik - tidak memerlukan token
Route::post('/auth/register', [AuthController::class, 'register']);
Route::post('/auth/login', [AuthController::class, 'login']);

Route::get('/books', [BookController::class, 'index']);
Route::get('/books/{id}/cover', [BookController::class, 'cover']);
Route::get('/books/{id}', [BookController::class, 'show']);

// Endpoint yang wajib login
Route::middleware('auth:sanctum')->group(function () {

    // Autentikasi
    Route::get('/auth/me', [AuthController::class, 'me']);
    Route::post('/auth/logout', [AuthController::class, 'logout']);

    // CRUD Buku
    Route::post('/books', [BookController::class, 'store']);
    Route::patch('/books/{id}', [BookController::class, 'update']);
    Route::delete('/books/{id}', [BookController::class, 'destroy']);

    // CRUD Peminjaman
    Route::get('/loans', [LoanController::class, 'index']);
    Route::post('/loans', [LoanController::class, 'store']);
    Route::get('/loans/{id}', [LoanController::class, 'show']);
    Route::patch('/loans/{id}', [LoanController::class, 'update']);
    Route::delete('/loans/{id}', [LoanController::class, 'destroy']);

});