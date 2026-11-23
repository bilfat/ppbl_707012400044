
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('loans', function (Blueprint $table) {
            $table->id();

            $table->foreignId('book_id')
                  ->constrained();

            $table->foreignId('user_id')
                  ->constrained();

            $table->date('tanggal_pinjam');
            $table->date('tanggal_kembali')->nullable();

            $table->enum('status', [
                'Dipinjam',
                'Dikembalikan'
            ])->default('Dipinjam');

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('loans');
    }
};
