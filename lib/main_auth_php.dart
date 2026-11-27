import 'package:flutter/material.dart';

import 'screens/akun_php_screen.dart';
import 'screens/login_php_screen.dart';
import 'screens/register_php_screen.dart';

/// Titik masuk terpisah untuk mencoba register/login ke backend PHP.
/// Jalankan: flutter run -t lib/main_auth_php.dart -d windows
void main() => runApp(const AuthPhpDemoApp());

class AuthPhpDemoApp extends StatelessWidget {
  const AuthPhpDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PustakaKita (Auth PHP)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPhpScreen(),
        '/register': (context) => const RegisterPhpScreen(),
        '/akun': (context) => const AkunPhpScreen(),
      },
    );
  }
}
