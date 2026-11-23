<?php

namespace App\Http\Controllers;

use App\Models\Book;
use Illuminate\Http\Request;
use App\Http\Requests\StoreBookRequest;
use App\Http\Requests\UpdateBookRequest;

class BookController extends Controller
{
    // GET /api/books - Menampilkan semua buku
    public function index()
    {
        return response()->json(
            Book::latest()->get()
        );
    }

    // POST /api/books - Menambahkan buku
    public function store(StoreBookRequest $request)
    {
        $book = Book::create($request->validated());

        return response()->json([
            'message' => 'Buku berhasil ditambahkan',
            'data' => $book
        ], 201);
    }

    // GET /api/books/{id} - Menampilkan detail buku
    public function show($id)
    {
        return response()->json(
            $this->findBook($id)
        );
    }

    // PATCH /api/books/{id} - Mengubah buku
    public function update(UpdateBookRequest $request, $id)
    {
        $book = $this->findBook($id);

        $book->update($request->validated());

        return response()->json([
            'message' => 'Buku berhasil diperbarui',
            'data' => $book
        ]);
    }

    // DELETE /api/books/{id} - Menghapus buku
    public function destroy($id)
    {
        $this->findBook($id)->delete();

        return response()->json([
            'message' => 'Buku berhasil dihapus'
        ]);
    }

    // Mencari buku berdasarkan ID
    private function findBook($id)
    {
        $book = Book::find($id);

        if (! $book) {
            abort(404, 'Buku tidak ditemukan');
        }

        return $book;
    }
}
