<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Casts\Attribute;

class Book extends Model
{
    protected $fillable = [
        'judul',
        'penulis',
        'penerbit',
        'tahun_terbit',
        'stok',
        'cover',
        'cover_name'
    ];

    protected $hidden = ['cover'];

    protected $appends = ['cover_url'];

    public function loans()
    {
        return $this->hasMany(Loan::class);
    }

    protected function coverUrl(): Attribute
    {
        return Attribute::get(
            fn () => $this->cover
                ? url("/api/books/{$this->id}/cover")
                : null
        );
    }
}