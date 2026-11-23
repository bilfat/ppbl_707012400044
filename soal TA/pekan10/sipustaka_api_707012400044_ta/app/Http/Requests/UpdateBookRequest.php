<?php

namespace App\Http\Requests;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;

class UpdateBookRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'judul' => ['sometimes', 'required', 'string', 'max:200'],
            'penulis' => ['sometimes', 'required', 'string', 'max:150'],
            'penerbit' => ['sometimes', 'required', 'string', 'max:150'],
            'tahun_terbit' => [
                'sometimes', 'required', 'integer', 'digits:4'
            ],
            'stok' => ['sometimes', 'required', 'integer', 'min:0'],
            'cover' => [
                'nullable', 'file', 'max:2048',
                'mimes:jpg,jpeg,png'
            ],
            'remove_cover' => ['sometimes', 'boolean'],
        ];
    }

    public function messages(): array
    {
        return [
            'cover.max' => 'Ukuran file cover maksimal 2 MB.',
            'cover.mimes' => 'Format file cover harus jpg, jpeg, atau png.',
            'cover.uploaded' => 'File cover gagal diunggah, periksa ukuran file.',
        ];
    }
}
