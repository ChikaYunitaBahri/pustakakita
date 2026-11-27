
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'screens/demo_setstate_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/buku_provider.dart';
import 'providers/favorit_provider.dart';
import 'providers/peminjaman_provider.dart';
import 'screens/detail_screen.dart';
import 'screens/home_shell.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Hive
  await Hive.initFlutter();

  // Membuka box untuk menyimpan data favorit
  await Hive.openBox('favorit');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PeminjamanProvider()..muat(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => BukuProvider()..muat(),
        ),
        ChangeNotifierProvider(
          create: (_) => FavoritProvider(Hive.box('favorit')),
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
    return MaterialApp(
      title: 'PustakaKita',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.terang,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeShell(),
        '/detail': (context) => const DetailScreen(),
        '/login': (context) => const LoginScreen(),
        '/demo-setstate': (context) => const DemoSetStateScreen(),
      },
    );
  }
}
