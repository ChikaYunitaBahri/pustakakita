
import 'package:flutter/material.dart';

/// Warna dan font identitas PustakaKita.
class AppTheme {
  static const Color warnaUtama = Color(0xFF3949AB);

  /// Tema terang PustakaKita.
  static ThemeData get terang {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      colorScheme: ColorScheme.fromSeed(
        seedColor: warnaUtama,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF8F9FF),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFFF8F9FF),
        selectedItemColor: warnaUtama,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  /// Tema gelap PustakaKita.
  static ThemeData get gelap {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      colorScheme: ColorScheme.fromSeed(
        seedColor: warnaUtama,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF121318),
      cardColor: const Color(0xFF1E2028),

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E2028),
        foregroundColor: Colors.white,
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E2028),
        selectedItemColor: Color(0xFF9FAEFF),
        unselectedItemColor: Color(0xFFB0B0B0),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
