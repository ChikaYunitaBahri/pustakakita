import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    await auth.logout();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berhasil logout'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Consumer<AuthProvider>(
            builder: (context, auth, _) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ikon profil
                const Icon(
                  Icons.account_circle,
                  size: 72,
                ),

                const SizedBox(height: 8),

                // Nama pengguna
                Text(
                  auth.sudahLogin
                      ? 'Halo, ${auth.namaUser}'
                      : 'Belum login',
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                // Email pengguna
                if (auth.email != null)
                  Text(auth.email!),

                const SizedBox(height: 16),

                // Tombol Login atau Logout
                if (auth.sudahLogin)
                  FilledButton.icon(
                    onPressed: () => _logout(context),
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                  )
                else
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/login'),
                    child: const Text('Ke halaman login'),
                  ),

                const SizedBox(height: 8),

                // Demo setState
                OutlinedButton(
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

                      // Pengaturan Dark Mode
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
      ),
    );
  }
}