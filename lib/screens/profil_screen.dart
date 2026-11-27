
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Consumer<AuthProvider>(
                builder: (context, auth, _) => Text(
                  auth.sudahLogin
                      ? 'Halo, ${auth.namaUser}'
                      : 'Belum login',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),

              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/login'),
                child: const Text('Ke halaman login'),
              ),

              ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/demo-setstate'),
                child: const Text('Demo setState'),
              ),

              const SizedBox(height: 32),

              // Pengaturan tampilan
              Card(
                child: Column(
                  children: [
                    const ListTile(
                      leading: Icon(Icons.settings_outlined),
                      title: Text('Pengaturan Tampilan'),
                    ),

                    SwitchListTile(
                      secondary: const Icon(Icons.dark_mode_outlined),
                      title: const Text('Dark Mode'),
                      subtitle: Text(
                        themeProvider.gelap
                            ? 'Mode gelap aktif'
                            : 'Mode terang aktif',
                      ),
                      value: themeProvider.gelap,
                      onChanged: (nilai) {
                        themeProvider.ubah(nilai);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
