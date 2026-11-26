import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Consumer<AuthProvider>(
              builder: (context, auth, _) => Text(
                auth.sudahLogin ? 'Halo, ${auth.namaUser}' : 'Belum login',
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: const Text('Ke halaman login'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/demo-setstate'),
              child: const Text('Demo setState'),
            ),
          ],
        ),
      ),
    );
  }
}