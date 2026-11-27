import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final navigator = Navigator.of(context);
    await context.read<AuthProvider>().logout();
    // AuthGate otomatis menampilkan halaman login setelah sesi dihapus.
    navigator.popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Center(
        child: Consumer<AuthProvider>(
          builder: (context, auth, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_circle, size: 72),
              const SizedBox(height: 8),
              Text(
                auth.sudahLogin ? 'Halo, ${auth.namaUser}' : 'Belum login',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (auth.email != null) Text(auth.email!),
              const SizedBox(height: 16),
              if (auth.sudahLogin)
                FilledButton.icon(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/demo-setstate'),
                child: const Text('Demo setState'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
