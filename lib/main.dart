import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'screens/auth_gate.dart';
import 'screens/demo_setstate_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/buku_provider.dart';
import 'providers/favorit_provider.dart';
import 'providers/peminjaman_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/detail_screen.dart';
import 'screens/login_php_screen.dart';
import 'screens/register_php_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Hive di folder data aplikasi (bukan folder Documents)
  final dir = await getApplicationSupportDirectory();
  await dir.create(recursive: true);
  Hive.init(dir.path);

  // Membuka box untuk menyimpan data favorit
  await Hive.openBox('favorit');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PeminjamanProvider()..muat(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..muat(),
        ),
        ChangeNotifierProvider(
          create: (_) => BukuProvider()..muat(),
        ),
        ChangeNotifierProvider(
          create: (_) => FavoritProvider(Hive.box('favorit')),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider()..muat(),
        ),
      ],
      child: const PustakaKitaApp(),
    ),
  );
}

class PustakaKitaApp extends StatelessWidget {
  const PustakaKitaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'PustakaKita',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.terang,
      darkTheme: AppTheme.gelap,
      themeMode: themeProvider.mode,
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthGate(),
        '/detail': (context) => const DetailScreen(),
        '/login': (context) => const LoginPhpScreen(),
        '/register': (context) => const RegisterPhpScreen(),
        '/demo-setstate': (context) => const DemoSetStateScreen(),
      },
    );
  }
}