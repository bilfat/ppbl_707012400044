import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../config/app_theme.dart';
import '../cubits/auth_cubit.dart';
import '../cubits/auth_state.dart';
import '../cubits/book_cubit.dart';
import '../cubits/book_state.dart';
import '../cubits/loan_cubit.dart';
import '../cubits/loan_state.dart';
import '../models/loan.dart';
import '../models/user.dart';
import '../widgets/book_card.dart';
import '../widgets/home_header.dart';
import '../widgets/info_view.dart';
import '../widgets/loan_card.dart';
import 'book_detail_page.dart';
import 'book_form_page.dart';
import 'loan_detail_page.dart';
import 'login_page.dart';

// ============================================================
// HALAMAN UTAMA SIPUSTAKA - KATALOG BUKU & PEMINJAMAN SAYA
// ============================================================
// Daftar & detail buku bisa dilihat tanpa login.
// Tambah, ubah, hapus buku dan fitur peminjaman hanya muncul setelah login.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedTab = 0;

  void _openLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  void _openAddBook() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BookFormPage()),
    );
  }

  /// Menampilkan bottom sheet profil + tombol Logout
  void _showProfile(User user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 76,
                height: 76,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  gradient: AppColors.mainGradient,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                user.email,
                style: const TextStyle(color: AppColors.textGrey),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    context.read<AuthCubit>().logout();
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Logout'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Dialog untuk mengecek peminjaman berdasarkan ID (GET /api/loans/{id}).
  /// Berguna untuk melihat detail maupun menguji hak akses 403 Forbidden.
  Future<void> _showCheckLoanByIdDialog() async {
    final controller = TextEditingController();
    final id = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Cek Peminjaman by ID'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'ID Peminjaman',
            hintText: 'Contoh: 1',
            prefixIcon: Icon(Icons.tag_rounded, color: AppColors.primary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              final parsed = int.tryParse(controller.text.trim());
              Navigator.pop(dialogContext, parsed);
            },
            child: const Text('Cek'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (id == null || !mounted) return;
    final loan = await context.read<LoanCubit>().loadLoanDetail(id);
    if (loan != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => LoanDetailPage(loan: loan)),
      );
    }
  }

  Future<void> _quickReturnLoan(Loan loan) async {
    final success = await context.read<LoanCubit>().returnLoan(loan.id);
    if (success && mounted) {
      await context.read<BookCubit>().loadBooks();
    }
  }

  Future<void> _confirmDeleteLoan(Loan loan) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: const Icon(Icons.delete_forever_rounded,
            color: AppColors.danger, size: 48),
        title: const Text('Hapus Peminjaman?'),
        content: Text(
          'Peminjaman #${loan.id} akan dihapus permanen.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (yakin != true || !mounted) return;
    final success = await context.read<LoanCubit>().deleteLoan(loan.id);
    if (success && mounted) {
      await context.read<BookCubit>().loadBooks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        return BlocBuilder<BookCubit, BookState>(
          builder: (context, bookState) {
            return BlocBuilder<LoanCubit, LoanState>(
              builder: (context, loanState) {
                final user = authState.user;
                final isLoggedIn = authState.isLoggedIn;

                return Scaffold(
                  // Tombol Tambah Buku hanya muncul setelah login
                  floatingActionButton: isLoggedIn && _selectedTab == 0
                      ? FloatingActionButton.extended(
                          onPressed: _openAddBook,
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Tambah Buku'),
                        )
                      : null,
                  bottomNavigationBar: NavigationBar(
                    selectedIndex: _selectedTab,
                    backgroundColor: Colors.white,
                    indicatorColor: AppColors.primary.withValues(alpha: 0.14),
                    onDestinationSelected: (index) {
                      setState(() => _selectedTab = index);
                      if (index == 1 && isLoggedIn) {
                        context.read<LoanCubit>().loadLoans();
                      }
                    },
                    destinations: const [
                      NavigationDestination(
                        icon: Icon(Icons.menu_book_outlined),
                        selectedIcon:
                            Icon(Icons.menu_book_rounded, color: AppColors.primary),
                        label: 'Katalog Buku',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.bookmark_border_rounded),
                        selectedIcon: Icon(Icons.bookmark_rounded,
                            color: AppColors.primary),
                        label: 'Peminjaman Saya',
                      ),
                    ],
                  ),
                  body: Column(
                    children: [
                      HomeHeader(
                        user: user,
                        isChecking: authState.isChecking,
                        totalBook: bookState.books.length,
                        myLoan: loanState.loans.length,
                        onLoginTap: _openLogin,
                        onProfileTap: () => _showProfile(user!),
                      ),
                      Expanded(
                        child: _selectedTab == 0
                            ? _buildBookList(bookState)
                            : _buildLoanList(loanState, isLoggedIn),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildBookList(BookState state) {
    final bookCubit = context.read<BookCubit>();

    if (state.isLoading && state.books.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorText != null && state.books.isEmpty) {
      return InfoView(
        icon: Icons.cloud_off_rounded,
        title: 'Oops, gagal terhubung',
        subtitle: state.errorText!,
        buttonText: 'Coba Lagi',
        onPressed: bookCubit.loadBooks,
      );
    }

    if (state.books.isEmpty) {
      return RefreshIndicator(
        onRefresh: bookCubit.loadBooks,
        child: ListView(
          children: const [
            SizedBox(height: 40),
            InfoView(
              icon: Icons.menu_book_outlined,
              title: 'Belum ada buku',
              subtitle: 'Tambahkan buku pertama ke katalog SiPustaka 📚',
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: bookCubit.loadBooks,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        itemCount: state.books.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 14),
              child: Text(
                'Katalog Buku 📚',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            );
          }

          final book = state.books[index - 1];
          return BookCard(
            book: book,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => BookDetailPage(book: book)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoanList(LoanState state, bool isLoggedIn) {
    if (!isLoggedIn) {
      return InfoView(
        icon: Icons.lock_outline_rounded,
        title: 'Login Diperlukan',
        subtitle: 'Masuk terlebih dahulu untuk melihat dan mengelola daftar peminjaman Anda.',
        buttonText: 'Login Sekarang',
        buttonIcon: Icons.login_rounded,
        onPressed: _openLogin,
      );
    }

    final loanCubit = context.read<LoanCubit>();

    if (state.isLoading && state.loans.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorText != null && state.loans.isEmpty) {
      return InfoView(
        icon: Icons.cloud_off_rounded,
        title: 'Oops, gagal memuat peminjaman',
        subtitle: state.errorText!,
        buttonText: 'Coba Lagi',
        onPressed: loanCubit.loadLoans,
      );
    }

    return RefreshIndicator(
      onRefresh: loanCubit.loadLoans,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          Row(
            children: [
              const Text(
                'Peminjaman Saya 📋',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _showCheckLoanByIdDialog,
                icon: const Icon(Icons.search_rounded, size: 18),
                label: const Text('Cek ID'),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (state.loans.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: InfoView(
                icon: Icons.bookmark_border_rounded,
                title: 'Belum ada peminjaman',
                subtitle: 'Buka detail buku di tab Katalog untuk mulai meminjam buku.',
              ),
            )
          else
            ...state.loans.map(
              (loan) => LoanCard(
                loan: loan,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LoanDetailPage(loan: loan)),
                ),
                onReturnTap:
                    loan.isReturned ? null : () => _quickReturnLoan(loan),
                onDeleteTap: () => _confirmDeleteLoan(loan),
              ),
            ),
        ],
      ),
    );
  }
}
