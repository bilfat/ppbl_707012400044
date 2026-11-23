
<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\BookController;

// CRUD Buku SiPustaka
Route::get('/books', [BookController::class, 'index']);
Route::post('/books', [BookController::class, 'store']);
Route::get('/books/{id}', [BookController::class, 'show']);
Route::patch('/books/{id}', [BookController::class, 'update']);
Route::delete('/books/{id}', [BookController::class, 'destroy']);
