import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'config/app_theme.dart';
import 'cubits/auth_cubit.dart';
import 'cubits/auth_state.dart';
import 'cubits/book_cubit.dart';
import 'cubits/book_state.dart';
import 'cubits/loan_cubit.dart';
import 'cubits/loan_state.dart';
import 'pages/home_page.dart';
import 'services/api_service.dart';
import 'utils/helpers.dart';

void main() {
  runApp(MyApp(api: ApiService()));
}

class MyApp extends StatelessWidget {
  final ApiService api;

  const MyApp({super.key, required this.api});

  @override
  Widget build(BuildContext context) {
    // 1. Daftarkan AuthCubit, BookCubit, dan LoanCubit agar dapat dipakai di semua halaman
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit(api)..checkLogin()),
        BlocProvider(create: (_) => BookCubit(api)..loadBooks()),
        BlocProvider(create: (_) => LoanCubit(api)),
      ],
      // 2. Dengarkan perubahan state untuk SnackBar & sinkronisasi peminjaman
      child: MultiBlocListener(
        listeners: [
          BlocListener<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state.message != null) {
                showMessage(state.message!, isError: state.isError);
              }
              if (state.isLoggedIn && !state.isLoading) {
                context.read<LoanCubit>().loadLoans();
              } else if (!state.isLoggedIn && !state.isChecking && !state.isLoading) {
                context.read<LoanCubit>().clearLoans();
              }
            },
          ),
          BlocListener<BookCubit, BookState>(
            listenWhen: (previous, current) => current.message != null,
            listener: (context, state) {
              showMessage(state.message!, isError: state.isError);
            },
          ),
          BlocListener<LoanCubit, LoanState>(
            listenWhen: (previous, current) => current.message != null,
            listener: (context, state) {
              showMessage(state.message!, isError: state.isError);
            },
          ),
        ],
        // 3. Aplikasi SiPustaka
        child: MaterialApp(
          title: 'SiPustaka',
          debugShowCheckedModeBanner: false,
          scaffoldMessengerKey: messengerKey,
          theme: AppTheme.light,
          home: const HomePage(),
        ),
      ),
    );
  }
}
