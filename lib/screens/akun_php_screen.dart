import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/auth_php_api.dart';

/// Halaman setelah login berhasil: data akun dan tombol logout.
class AkunPhpScreen extends StatelessWidget {
  const AkunPhpScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final navigator = Navigator.of(context);
    await context.read<AuthProvider>().logout();
    navigator.pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final akun = AuthPhpApi.akun;

    return Scaffold(
      appBar: AppBar(title: const Text('Akun Saya')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: akun == null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Anda belum login'),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => Navigator.pushNamedAndRemoveUntil(
                            context, '/login', (route) => false),
                        child: const Text('Ke halaman login'),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.account_circle, size: 72),
                      const SizedBox(height: 12),
                      Text(
                        'Halo, ${akun.nama}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(akun.email, textAlign: TextAlign.center),
                      const SizedBox(height: 24),
                      OutlinedButton.icon(
                        onPressed: () => _logout(context),
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
