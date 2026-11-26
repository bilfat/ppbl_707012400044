<?php

namespace Tests\Feature;

use App\Models\Book;
use App\Models\Loan;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class SiPustakaApiTest extends TestCase
{
    use RefreshDatabase;

    private function createAuthenticatedUser(string $name, string $email, string $password = 'praktikum123'): array
    {
        $this->postJson('/api/auth/register', [
            'name' => $name,
            'email' => $email,
            'password' => $password,
        ])->assertCreated();

        $login = $this->postJson('/api/auth/login', [
            'email' => $email,
            'password' => $password,
        ])->assertOk();

        return [
            'user' => User::where('email', $email)->firstOrFail(),
            'token' => $login->json('access_token'),
        ];
    }

    public function test_auth_register_login_me_logout_and_errors(): void
    {
        // Register validation error (422)
        $this->postJson('/api/auth/register', [
            'name' => '',
            'email' => 'bukan-email',
            'password' => '123',
        ])->assertUnprocessable()
            ->assertJsonValidationErrors(['name', 'email', 'password']);

        // Register success (201)
        $this->postJson('/api/auth/register', [
            'name' => 'Budi Santoso',
            'email' => 'budi@example.com',
            'password' => 'praktikum123',
        ])->assertCreated()
            ->assertJsonPath('message', 'Registrasi berhasil')
            ->assertJsonPath('user.email', 'budi@example.com');

        // Duplicate email (409)
        $this->postJson('/api/auth/register', [
            'name' => 'Budi Duplikat',
            'email' => 'budi@example.com',
            'password' => 'praktikum123',
        ])->assertStatus(409)
            ->assertJsonPath('message', 'Email sudah terdaftar');

        // Login wrong password (401)
        $this->postJson('/api/auth/login', [
            'email' => 'budi@example.com',
            'password' => 'salah12345',
        ])->assertUnauthorized();

        // Login success (200)
        $login = $this->postJson('/api/auth/login', [
            'email' => 'budi@example.com',
            'password' => 'praktikum123',
        ])->assertOk()
            ->assertJsonStructure(['message', 'token_type', 'access_token', 'user']);

        $token = $login->json('access_token');

        // Me without token (401) - even without Accept: application/json
        $this->get('/api/auth/me')->assertUnauthorized();

        // Me with token (200)
        $this->withToken($token)
            ->getJson('/api/auth/me')
            ->assertOk()
            ->assertJsonPath('email', 'budi@example.com');

        // Logout (200)
        $this->withToken($token)
            ->postJson('/api/auth/logout')
            ->assertOk()
            ->assertJsonPath('message', 'Logout berhasil');

        // Token revoked after logout (401)
        $this->app['auth']->forgetGuards();
        $this->withToken($token)
            ->getJson('/api/auth/me')
            ->assertUnauthorized();
    }

    public function test_books_crud_public_read_auth_write_and_validation(): void
    {
        $budi = $this->createAuthenticatedUser('Budi Santoso', 'budi@example.com');

        // Public GET /api/books without token (200)
        $this->getJson('/api/books')->assertOk()->assertExactJson([]);

        // Create book without token (401)
        $this->postJson('/api/books', [
            'judul' => 'Pemrograman Laravel',
            'penulis' => 'Budi',
            'penerbit' => 'Informatika',
            'tahun_terbit' => 2025,
            'stok' => 5,
        ])->assertUnauthorized();

        // Validation error: empty judul and non-numeric stok (422)
        $this->withToken($budi['token'])
            ->postJson('/api/books', [
                'judul' => '',
                'penulis' => 'Budi',
                'penerbit' => 'Informatika',
                'tahun_terbit' => 25,
                'stok' => 'lima',
            ])->assertUnprocessable()
            ->assertJsonValidationErrors(['judul', 'tahun_terbit', 'stok']);

        // Create book valid without cover (201)
        $create = $this->withToken($budi['token'])
            ->postJson('/api/books', [
                'judul' => 'Clean Code',
                'penulis' => 'Robert C. Martin',
                'penerbit' => 'Prentice Hall',
                'tahun_terbit' => 2008,
                'stok' => 5,
            ])->assertCreated()
            ->assertJsonPath('judul', 'Clean Code')
            ->assertJsonPath('cover_url', null)
            ->assertJsonMissingPath('cover');

        $bookId = $create->json('id');

        // Public GET /api/books/{id} (200)
        $this->getJson("/api/books/{$bookId}")
            ->assertOk()
            ->assertJsonPath('judul', 'Clean Code');

        // GET non-existent book (404)
        $this->getJson('/api/books/9999')->assertNotFound();

        // Update book with token (200)
        $this->withToken($budi['token'])
            ->patchJson("/api/books/{$bookId}", [
                'judul' => 'Clean Code (Edisi Revisi)',
                'stok' => 10,
            ])->assertOk()
            ->assertJsonPath('judul', 'Clean Code (Edisi Revisi)')
            ->assertJsonPath('stok', 10);

        // Delete book with token (200)
        $this->withToken($budi['token'])
            ->deleteJson("/api/books/{$bookId}")
            ->assertOk()
            ->assertJsonPath('message', 'Buku berhasil dihapus');

        $this->getJson("/api/books/{$bookId}")->assertNotFound();
    }

    public function test_books_cover_upload_serve_replace_remove_delete_and_validation(): void
    {
        Storage::fake('local');
        $budi = $this->createAuthenticatedUser('Budi Santoso', 'budi@example.com');

        // Upload wrong file format (.txt) -> 422
        $wrongFormat = UploadedFile::fake()->create('dokumen.txt', 100, 'text/plain');
        $this->withToken($budi['token'])
            ->post('/api/books', [
                'judul' => 'Buku Format Salah',
                'penulis' => 'Penulis',
                'penerbit' => 'Penerbit',
                'tahun_terbit' => 2024,
                'stok' => 3,
                'cover' => $wrongFormat,
            ], ['Accept' => 'application/json'])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['cover']);

        // Upload oversized image (> 2 MB = 2048 KB) -> 422
        $tooBig = UploadedFile::fake()->create('besar.png', 2500, 'image/png');
        $this->withToken($budi['token'])
            ->post('/api/books', [
                'judul' => 'Buku File Besar',
                'penulis' => 'Penulis',
                'penerbit' => 'Penerbit',
                'tahun_terbit' => 2024,
                'stok' => 3,
                'cover' => $tooBig,
            ], ['Accept' => 'application/json'])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['cover']);

        // Upload valid PNG cover -> 201
        $sampleDir = base_path('postman/sample_files');
        $validCover1 = UploadedFile::fake()->createWithContent(
            'cover1.png',
            file_get_contents($sampleDir.'/cover_buku_1.png')
        );
        $create = $this->withToken($budi['token'])
            ->post('/api/books', [
                'judul' => 'Laravel REST API',
                'penulis' => 'Tim Praktikum',
                'penerbit' => 'Telkom University',
                'tahun_terbit' => 2026,
                'stok' => 4,
                'cover' => $validCover1,
            ], ['Accept' => 'application/json'])
            ->assertCreated()
            ->assertJsonPath('cover_name', 'cover1.png')
            ->assertJsonMissingPath('cover');

        $bookId = $create->json('id');
        $book = Book::findOrFail($bookId);
        $oldCoverPath = $book->cover;

        $this->assertNotNull($oldCoverPath);
        Storage::disk('local')->assertExists($oldCoverPath);
        $this->assertStringEndsWith("/api/books/{$bookId}/cover", $create->json('cover_url'));

        // Public GET /api/books/{id}/cover without token -> 200
        $this->get("/api/books/{$bookId}/cover")->assertOk();

        // Replace cover via POST + _method=PATCH -> 200, old cover deleted
        $validCover2 = UploadedFile::fake()->createWithContent(
            'cover2.jpg',
            file_get_contents($sampleDir.'/cover_buku_2.jpg')
        );
        $this->withToken($budi['token'])
            ->post("/api/books/{$bookId}", [
                '_method' => 'PATCH',
                'judul' => 'Laravel REST API v2',
                'cover' => $validCover2,
            ], ['Accept' => 'application/json'])
            ->assertOk()
            ->assertJsonPath('judul', 'Laravel REST API v2')
            ->assertJsonPath('cover_name', 'cover2.jpg');

        $book->refresh();
        $newCoverPath = $book->cover;
        Storage::disk('local')->assertMissing($oldCoverPath);
        Storage::disk('local')->assertExists($newCoverPath);

        // Remove cover only via remove_cover=true -> 200, cover_url becomes null, file deleted
        $this->withToken($budi['token'])
            ->patchJson("/api/books/{$bookId}", [
                'remove_cover' => true,
            ])->assertOk()
            ->assertJsonPath('cover_name', null)
            ->assertJsonPath('cover_url', null);

        Storage::disk('local')->assertMissing($newCoverPath);
        $this->getJson("/api/books/{$bookId}/cover")->assertNotFound();

        // Re-upload cover then delete book -> file must also be deleted
        $validCover3 = UploadedFile::fake()->createWithContent(
            'cover3.png',
            file_get_contents($sampleDir.'/cover_buku_1.png')
        );
        $this->withToken($budi['token'])
            ->post("/api/books/{$bookId}", [
                '_method' => 'PATCH',
                'cover' => $validCover3,
            ], ['Accept' => 'application/json'])
            ->assertOk();

        $book->refresh();
        $thirdCoverPath = $book->cover;
        Storage::disk('local')->assertExists($thirdCoverPath);

        $this->withToken($budi['token'])
            ->deleteJson("/api/books/{$bookId}")
            ->assertOk();

        Storage::disk('local')->assertMissing($thirdCoverPath);
    }

    public function test_loans_crud_stock_management_and_ownership_authorization(): void
    {
        $budi = $this->createAuthenticatedUser('Budi Santoso', 'budi@example.com');
        $andi = $this->createAuthenticatedUser('Andi Pratama', 'andi@example.com');

        // Loans without token -> 401
        $this->getJson('/api/loans')->assertUnauthorized();

        // Create book with stock 2
        $bookRes = $this->withToken($budi['token'])
            ->postJson('/api/books', [
                'judul' => 'Algoritma Pemrograman',
                'penulis' => 'Rinaldi Munir',
                'penerbit' => 'Informatika',
                'tahun_terbit' => 2022,
                'stok' => 2,
            ])->assertCreated();
        $bookId = $bookRes->json('id');

        // Validation error on loan create -> 422
        $this->withToken($budi['token'])
            ->postJson('/api/loans', [
                'book_id' => 9999,
                'tanggal_pinjam' => '23-11-2026',
            ])->assertUnprocessable()
            ->assertJsonValidationErrors(['book_id', 'tanggal_pinjam']);

        // Budi borrows book -> 201, stock becomes 1
        $loanRes = $this->withToken($budi['token'])
            ->postJson('/api/loans', [
                'book_id' => $bookId,
                'tanggal_pinjam' => '2026-11-23',
            ])->assertCreated()
            ->assertJsonPath('status', 'Dipinjam')
            ->assertJsonPath('book.id', $bookId);

        $loanId = $loanRes->json('id');
        $this->assertEquals(1, Book::findOrFail($bookId)->stok);

        // Budi sees his loan
        $this->withToken($budi['token'])
            ->getJson('/api/loans')
            ->assertOk()
            ->assertJsonCount(1);

        // Andi cannot view, update, or delete Budi's loan -> 403
        $this->app['auth']->forgetGuards();
        $this->withToken($andi['token'])
            ->getJson("/api/loans/{$loanId}")
            ->assertForbidden();

        $this->withToken($andi['token'])
            ->patchJson("/api/loans/{$loanId}", ['status' => 'Dikembalikan'])
            ->assertForbidden();

        $this->withToken($andi['token'])
            ->deleteJson("/api/loans/{$loanId}")
            ->assertForbidden();

        // Switch back to Budi
        $this->app['auth']->forgetGuards();

        // Book with loan history cannot be deleted -> 409
        $this->withToken($budi['token'])
            ->deleteJson("/api/books/{$bookId}")
            ->assertStatus(409);

        // Budi returns book -> 200, stock back to 2
        $this->withToken($budi['token'])
            ->patchJson("/api/loans/{$loanId}", [
                'status' => 'Dikembalikan',
                'tanggal_kembali' => '2026-11-25',
            ])->assertOk()
            ->assertJsonPath('status', 'Dikembalikan')
            ->assertJsonPath('tanggal_kembali', '2026-11-25');

        $this->assertEquals(2, Book::findOrFail($bookId)->stok);

        // Cannot reopen returned loan -> 422
        $this->withToken($budi['token'])
            ->patchJson("/api/loans/{$loanId}", [
                'status' => 'Dipinjam',
            ])->assertUnprocessable();

        // Budi deletes his own loan -> 200
        $this->withToken($budi['token'])
            ->deleteJson("/api/loans/{$loanId}")
            ->assertOk()
            ->assertJsonPath('message', 'Peminjaman berhasil dihapus');

        // Delete non-existent loan -> 404
        $this->withToken($budi['token'])
            ->deleteJson('/api/loans/9999')
            ->assertNotFound();

        // Stock out test -> 422
        $emptyBook = $this->withToken($budi['token'])
            ->postJson('/api/books', [
                'judul' => 'Buku Stok Nol',
                'penulis' => 'Anonim',
                'penerbit' => 'Kampus',
                'tahun_terbit' => 2025,
                'stok' => 0,
            ])->assertCreated();

        $this->withToken($budi['token'])
            ->postJson('/api/loans', [
                'book_id' => $emptyBook->json('id'),
                'tanggal_pinjam' => '2026-11-23',
            ])->assertUnprocessable()
            ->assertJsonValidationErrors(['book_id']);
    }
}
