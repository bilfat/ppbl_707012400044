<?php

namespace App\Http\Controllers;

use App\Models\Book;
use App\Http\Requests\StoreBookRequest;
use App\Http\Requests\UpdateBookRequest;
use Illuminate\Support\Facades\Storage;

class BookController extends Controller
{
    // GET /api/books
    // Menampilkan semua buku
    public function index()
    {
        return response()->json(Book::latest()->get());
    }

    // GET /api/books/{id}
    // Menampilkan satu buku
    public function show($id)
    {
        return response()->json($this->findBook($id));
    }

    // POST /api/books
    // Menambahkan buku
    public function store(StoreBookRequest $request)
    {
        $data = $request->safe()->only([
            'judul', 'penulis', 'penerbit',
            'tahun_terbit', 'stok'
        ]);

        if ($request->hasFile('cover')) {
            $file = $request->file('cover');

            $data['cover'] = $file->store('books', 'local');
            $data['cover_name'] = $file->getClientOriginalName();
        }

        $book = Book::create($data);

        return response()->json($book, 201);
    }

    // PATCH /api/books/{id}
    // Mengubah buku dan mengganti cover
    public function update(UpdateBookRequest $request, $id)
    {
        $book = $this->findBook($id);

        $data = $request->safe()->only([
            'judul', 'penulis', 'penerbit',
            'tahun_terbit', 'stok'
        ]);

        if ($request->hasFile('cover')) {
            if ($book->cover) {
                Storage::disk('local')->delete($book->cover);
            }

            $file = $request->file('cover');

            $data['cover'] = $file->store('books', 'local');
            $data['cover_name'] = $file->getClientOriginalName();

        } elseif ($request->boolean('remove_cover')) {
            if ($book->cover) {
                Storage::disk('local')->delete($book->cover);
            }

            $data['cover'] = null;
            $data['cover_name'] = null;
        }

        $book->update($data);

        return response()->json($book->fresh());
    }

    // DELETE /api/books/{id}
    // Menghapus buku dan cover
    public function destroy($id)
    {
        $book = $this->findBook($id);

        // Jangan hapus buku yang punya riwayat peminjaman
        if ($book->loans()->exists()) {
            return response()->json([
                'message' => 'Buku memiliki riwayat peminjaman'
            ], 409);
        }

        if ($book->cover) {
            Storage::disk('local')->delete($book->cover);
        }

        $book->delete();

        return response()->json([
            'message' => 'Buku berhasil dihapus'
        ]);
    }

    // GET /api/books/{id}/cover
    // Membuka gambar sampul tanpa login
    public function cover($id)
    {
        $book = $this->findBook($id);

        if (!$book->cover ||
            !Storage::disk('local')->exists($book->cover)) {
            abort(404, 'Cover tidak ditemukan');
        }

        return Storage::disk('local')->response(
            $book->cover,
            $book->cover_name ?? 'cover.jpg',
            [],
            'inline'
        );
    }

    // Mencari buku, jika tidak ditemukan kirim 404
    private function findBook($id): Book
    {
        $book = Book::find($id);

        if (!$book) {
            abort(404, 'Buku tidak ditemukan');
        }

        return $book;
    }
}