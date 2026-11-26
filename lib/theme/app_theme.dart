import 'package:flutter/material.dart';

/// Warna dan font identitas PustakaKita.
class AppTheme {
  static const Color warnaUtama = Color(0xFF3949AB);

  static ThemeData get terang {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      colorScheme: ColorScheme.fromSeed(seedColor: warnaUtama),
    );
  }
}