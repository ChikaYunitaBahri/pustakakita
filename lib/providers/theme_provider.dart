
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const _key = 'mode_gelap';

  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;
  bool get gelap => _mode == ThemeMode.dark;

  Future<void> muat() async {
    final prefs = await SharedPreferences.getInstance();

    _mode = (prefs.getBool(_key) ?? false)
        ? ThemeMode.dark
        : ThemeMode.light;

    notifyListeners();
  }

  Future<void> ubah(bool nilai) async {
    _mode = nilai ? ThemeMode.dark : ThemeMode.light;

    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, nilai);
  }
}
