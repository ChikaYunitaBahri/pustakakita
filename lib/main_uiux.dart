import 'package:flutter/material.dart';

import 'screens/detail_screen.dart';
import 'screens/katalog_cari_screen.dart';
import 'screens/login_form_screen.dart';

/// Titik masuk terpisah untuk mencoba layar UI/UX tanpa mengubah main.dart.
/// Jalankan: flutter run -t lib/main_uiux.dart
void main() => runApp(const UiuxDemoApp());

class UiuxDemoApp extends StatelessWidget {
  const UiuxDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PustakaKita (UI/UX)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      initialRoute: '/login',
      routes: {
        '/': (context) => const KatalogCariScreen(),
        '/detail': (context) => const DetailScreen(),
        '/login': (context) => const LoginFormScreen(),
      },
    );
  }
}
