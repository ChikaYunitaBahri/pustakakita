import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'home_shell.dart';
import 'login_php_screen.dart';

/// Penjaga halaman: pengguna yang belum login selalu diarahkan ke halaman
/// login. Setelah login atau logout, tampilan berganti otomatis.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.siap) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!auth.sudahLogin) return const LoginPhpScreen();
    return const HomeShell();
  }
}
