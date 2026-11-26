import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/buku_provider.dart';
import 'providers/peminjaman_provider.dart';
import 'screens/detail_screen.dart';
import 'screens/home_shell.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PeminjamanProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BukuProvider()..muat()),
      ],
      child: const PustakaKitaApp(),
    ),
  );
}

class PustakaKitaApp extends StatelessWidget {
  const PustakaKitaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PustakaKita',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.terang,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeShell(),
        '/detail': (context) => const DetailScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}