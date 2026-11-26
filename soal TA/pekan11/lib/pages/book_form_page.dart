import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../config/app_theme.dart';
import '../cubits/book_cubit.dart';
import '../cubits/book_state.dart';
import '../models/book.dart';
import '../models/upload_file.dart';
import '../utils/helpers.dart';
import '../widgets/app_text_field.dart';
import '../widgets/attachment_tile.dart';
import '../widgets/gradient_button.dart';

// ============================================================
// HALAMAN FORM BUKU
// ============================================================
// Satu halaman untuk dua fungsi:
//   - book == null -> TAMBAH buku (POST /api/books)
//   - book != null -> UBAH buku   (POST /api/books/{id} + _method=PATCH)
//
// Mendukung upload sampul (jpg, jpeg, png, maksimal 2 MB) dengan pratinjau.
class BookFormPage extends StatefulWidget {
  final Book? book;

  const BookFormPage({super.key, this.book});

  @override
  State<BookFormPage> createState() => _BookFormPageState();
}

class _BookFormPageState extends State<BookFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _judulController;
  late final TextEditingController _penulisController;
  late final TextEditingController _penerbitController;
  late final TextEditingController _tahunController;
  late final TextEditingController _stokController;

  UploadFile? _newCover;
  bool _removeOldCover = false;

  bool get isEdit => widget.book != null;

  bool get _showOldCover =>
      isEdit && widget.book!.hasCover && !_removeOldCover && _newCover == null;

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: widget.book?.judul ?? '');
    _penulisController =
        TextEditingController(text: widget.book?.penulis ?? '');
    _penerbitController =
        TextEditingController(text: widget.book?.penerbit ?? '');
    _tahunController = TextEditingController(
      text: widget.book != null ? widget.book!.tahunTerbit.toString() : '',
    );
    _stokController = TextEditingController(
      text: widget.book != null ? widget.book!.stok.toString() : '',
    );
  }

  @override
  void dispose() {
    _judulController.dispose();
    _penulisController.dispose();
    _penerbitController.dispose();
    _tahunController.dispose();
    _stokController.dispose();
    super.dispose();
  }

  /// Memilih file sampul dari perangkat.
  /// Menggunakan FileType.any lalu memeriksa format (jpg/jpeg/png) dan ukuran (<= 2 MB)
  /// agar pengujian format salah dan file terlalu besar dapat diuji dengan jelas.
  Future<void> _pickCover() async {
    final result = await FilePicker.pickFiles(
      type: FileType.any,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final picked = result.files.first;
    if (!isAllowedCoverFile(picked.name)) {
      showMessage(
        'Format file sampul harus jpg, jpeg, atau png',
        isError: true,
      );
      return;
    }

    final bytes = picked.bytes;
    if (bytes == null) {
      showMessage('Gagal membaca isi file sampul', isError: true);
      return;
    }

    if (bytes.length > maxCoverSize) {
      showMessage('Ukuran file sampul maksimal 2 MB', isError: true);
      return;
    }

    setState(() {
      _newCover = UploadFile(name: picked.name, bytes: bytes);
      _removeOldCover = false;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final judul = _judulController.text.trim();
    final penulis = _penulisController.text.trim();
    final penerbit = _penerbitController.text.trim();
    final tahunTerbit = int.tryParse(_tahunController.text.trim()) ?? 0;
    final stok = int.tryParse(_stokController.text.trim()) ?? 0;

    final bookCubit = context.read<BookCubit>();
    final bool success;

    if (isEdit) {
      success = await bookCubit.updateBook(
        widget.book!.id,
        judul: judul,
        penulis: penulis,
        penerbit: penerbit,
        tahunTerbit: tahunTerbit,
        stok: stok,
        cover: _newCover,
        removeCover: _removeOldCover && _newCover == null,
      );
    } else {
      success = await bookCubit.createBook(
        judul: judul,
        penulis: penulis,
        penerbit: penerbit,
        tahunTerbit: tahunTerbit,
        stok: stok,
        cover: _newCover,
      );
    }

    if (success && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Ubah Buku' : 'Tambah Buku Baru'),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.mainGradient),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Kotak tips
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lightbulb_rounded, color: AppColors.primary),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tips: lengkapi data buku dan unggah sampul agar katalog lebih menarik ✨',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Kartu form buku
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    AppTextField(
                      controller: _judulController,
                      label: 'Judul Buku',
                      icon: Icons.book_rounded,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Judul buku wajib diisi';
                        }
                        if (value.length > 200) {
                          return 'Judul maksimal 200 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _penulisController,
                      label: 'Penulis',
                      icon: Icons.person_outline_rounded,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Penulis wajib diisi';
                        }
                        if (value.length > 150) {
                          return 'Penulis maksimal 150 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _penerbitController,
                      label: 'Penerbit',
                      icon: Icons.business_rounded,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Penerbit wajib diisi';
                        }
                        if (value.length > 150) {
                          return 'Penerbit maksimal 150 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _tahunController,
                            label: 'Tahun Terbit',
                            icon: Icons.calendar_today_rounded,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Tahun wajib diisi';
                              }
                              if (int.tryParse(value.trim()) == null) {
                                return 'Harus angka';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppTextField(
                            controller: _stokController,
                            label: 'Stok',
                            icon: Icons.inventory_2_outlined,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Stok wajib diisi';
                              }
                              if (int.tryParse(value.trim()) == null) {
                                return 'Harus angka';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Kartu sampul buku
              _buildCoverCard(),
              const SizedBox(height: 28),

              BlocBuilder<BookCubit, BookState>(
                builder: (context, state) {
                  return GradientButton(
                    text: isEdit ? 'Simpan Perubahan' : 'Simpan Buku',
                    icon: isEdit ? Icons.save_rounded : Icons.add_circle_rounded,
                    isLoading: state.isSaving,
                    onPressed: _save,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverCard() {
    final hasCover = _newCover != null || _showOldCover;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.image_rounded, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Sampul Buku (opsional)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 1. Sampul baru yang dipilih
          if (_newCover != null) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(
                  _newCover!.bytes,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            AttachmentTile(
              fileName: _newCover!.name,
              subtitle: '${_newCover!.sizeText} • sampul baru',
              trailing: IconButton(
                tooltip: 'Batal pilih',
                icon: const Icon(Icons.close_rounded, color: AppColors.danger),
                onPressed: () => setState(() => _newCover = null),
              ),
            ),
          ]
          // 2. Sampul lama (mode ubah)
          else if (_showOldCover) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  widget.book!.imageUrl,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(
                    height: 120,
                    child: Center(
                      child: Icon(Icons.broken_image_rounded,
                          size: 48, color: AppColors.textGrey),
                    ),
                  ),
                ),
              ),
            ),
            AttachmentTile(
              fileName: widget.book!.coverName ?? 'sampul.jpg',
              subtitle: 'Sampul saat ini',
              trailing: IconButton(
                tooltip: 'Hapus sampul',
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.danger),
                onPressed: () => setState(() => _removeOldCover = true),
              ),
            ),
          ],

          if (hasCover) const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: _pickCover,
            icon: Icon(hasCover
                ? Icons.swap_horiz_rounded
                : Icons.cloud_upload_outlined),
            label: Text(hasCover ? 'Ganti Sampul' : 'Pilih Sampul'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.5),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Format jpg, jpeg, png • maks. 2 MB',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }
}
