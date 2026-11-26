<?php

namespace App\Http\Controllers;

use App\Models\Book;
use App\Models\Loan;
use App\Http\Requests\StoreLoanRequest;
use App\Http\Requests\UpdateLoanRequest;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class LoanController extends Controller
{
    // GET /api/loans
    // Melihat peminjaman milik pengguna login
    public function index(Request $request)
    {
        $loans = $request->user()
            ->loans()
            ->with('book')
            ->latest()
            ->get();

        return response()->json($loans);
    }

    // POST /api/loans
    // Membuat peminjaman
    public function store(StoreLoanRequest $request)
    {
        $data = $request->validated();

        $loan = DB::transaction(function () use ($request, $data) {
            $book = Book::lockForUpdate()
                ->findOrFail($data['book_id']);

            if ($book->stok < 1) {
                throw ValidationException::withMessages([
                    'book_id' => 'Stok buku habis.'
                ]);
            }

            $book->decrement('stok');

            return $request->user()->loans()->create([
                'book_id' => $book->id,
                'tanggal_pinjam' => $data['tanggal_pinjam'],
                'tanggal_kembali' => null,
                'status' => 'Dipinjam'
            ]);
        });

        return response()->json($loan->load('book'), 201);
    }

    // GET /api/loans/{id}
    // Melihat peminjaman milik sendiri
    public function show(Request $request, $id)
    {
        $loan = $this->findOwnedLoan($request, $id);

        return response()->json($loan->load('book'));
    }

    // PATCH /api/loans/{id}
    // Mengubah peminjaman milik sendiri
    public function update(UpdateLoanRequest $request, $id)
    {
        $loan = $this->findOwnedLoan($request, $id);
        $data = $request->validated();

        $newStatus = $data['status'] ?? $loan->status;

        // Peminjaman selesai tidak boleh dibuka ulang
        if ($loan->status === 'Dikembalikan' &&
            $newStatus === 'Dipinjam') {
            throw ValidationException::withMessages([
                'status' => 'Peminjaman sudah dikembalikan.'
            ]);
        }

        // Tanggal kembali tidak boleh diisi saat masih dipinjam
        if ($newStatus === 'Dipinjam' &&
            !empty($data['tanggal_kembali'])) {
            throw ValidationException::withMessages([
                'tanggal_kembali' => 'Buku belum dikembalikan.'
            ]);
        }

        if ($newStatus === 'Dikembalikan') {
            $data['tanggal_kembali'] =
                $data['tanggal_kembali']
                ?? $loan->tanggal_kembali
                ?? now()->toDateString();

            $tanggalPinjam =
                $data['tanggal_pinjam'] ?? $loan->tanggal_pinjam;

            if ($data['tanggal_kembali'] < $tanggalPinjam) {
                throw ValidationException::withMessages([
                    'tanggal_kembali' =>
                        'Tanggal kembali tidak boleh sebelum tanggal pinjam.'
                ]);
            }
        }

        DB::transaction(function () use ($loan, $data, $newStatus) {
            if ($loan->status === 'Dipinjam' &&
                $newStatus === 'Dikembalikan') {
                Book::whereKey($loan->book_id)->increment('stok');
            }

            $loan->update($data);
        });

        return response()->json($loan->fresh()->load('book'));
    }

    // DELETE /api/loans/{id}
    // Menghapus peminjaman milik sendiri
    public function destroy(Request $request, $id)
    {
        $loan = $this->findOwnedLoan($request, $id);

        DB::transaction(function () use ($loan) {
            // Kembalikan stok jika buku masih berstatus Dipinjam
            if ($loan->status === 'Dipinjam') {
                Book::whereKey($loan->book_id)->increment('stok');
            }

            $loan->delete();
        });

        return response()->json([
            'message' => 'Peminjaman berhasil dihapus'
        ]);
    }

    // Memastikan peminjaman dimiliki pengguna login
    private function findOwnedLoan(Request $request, $id)
    {
        $loan = Loan::find($id);

        if (!$loan) {
            abort(404, 'Peminjaman tidak ditemukan');
        }

        if ($loan->user_id != $request->user()->id) {
            abort(403, 'Anda bukan pemilik peminjaman ini');
        }

        return $loan;
    }
}