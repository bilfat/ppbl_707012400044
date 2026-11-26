import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/user.dart';

/// Header berwarna gradasi di halaman utama SiPustaka.
/// Berisi sapaan, tombol login / foto profil, dan statistik buku & pinjaman.
class HomeHeader extends StatelessWidget {
  final User? user;
  final bool isChecking;
  final int totalBook;
  final int myLoan;
  final VoidCallback onLoginTap;
  final VoidCallback onProfileTap;

  const HomeHeader({
    super.key,
    required this.user,
    required this.isChecking,
    required this.totalBook,
    required this.myLoan,
    required this.onLoginTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, topPadding + 18, 24, 24),
      decoration: const BoxDecoration(
        gradient: AppColors.mainGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user == null ? 'Halo, Tamu 👋' : 'Halo, ${user!.name} 👋',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Jelajahi katalog dan kelola peminjaman SiPustaka',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (!isChecking)
                user == null ? _loginButton() : _profileButton(),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  icon: Icons.menu_book_rounded,
                  value: '$totalBook',
                  label: 'Total Buku',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatBox(
                  icon: Icons.bookmark_added_rounded,
                  value: user == null ? '-' : '$myLoan',
                  label: 'Pinjaman Saya',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _loginButton() {
    return ElevatedButton.icon(
      onPressed: onLoginTap,
      icon: const Icon(Icons.login_rounded, size: 18),
      label: const Text('Login'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        shape: const StadiumBorder(),
      ),
    );
  }

  Widget _profileButton() {
    return GestureDetector(
      onTap: onProfileTap,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
          child: Text(
            user!.name.isEmpty ? '?' : user!.name[0].toUpperCase(),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatBox({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
