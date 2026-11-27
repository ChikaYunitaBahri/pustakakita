import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_php_api.dart';

/// Menyimpan sesi login. Token dan data akun disimpan di SharedPreferences
/// agar sesi tetap ada setelah aplikasi ditutup, dan dihapus saat logout.
class AuthProvider extends ChangeNotifier {
  static const _kToken = 'auth_token';
  static const _kNama = 'auth_nama';
  static const _kEmail = 'auth_email';

  String? _namaUser;
  String? _email;
  String? _token;
  bool _siap = false;

  String? get namaUser => _namaUser;
  String? get email => _email;
  String? get token => _token;

  /// true setelah sesi tersimpan selesai dibaca dari SharedPreferences.
  bool get siap => _siap;
  bool get sudahLogin => _token != null;

  /// Dipanggil sekali saat aplikasi dibuka: memulihkan sesi yang tersimpan.
  Future<void> muat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_kToken);
      final nama = prefs.getString(_kNama);
      final email = prefs.getString(_kEmail);
      if (token != null && nama != null && email != null) {
        _token = token;
        _namaUser = nama;
        _email = email;
        // Agar logout ke server tetap bisa mengirim token yang dipulihkan.
        AuthPhpApi.akun = AkunPhp(nama: nama, email: email, token: token);
      }
    } catch (_) {
      // Jika penyimpanan gagal dibaca, anggap belum login.
    }
    _siap = true;
    notifyListeners();
  }

  /// Login ke backend PHP lalu simpan sesinya. Melempar [AuthPhpException]
  /// jika email atau password salah, atau server tidak bisa dihubungi.
  Future<void> login(String email, String password) async {
    final akun = await AuthPhpApi.login(email, password);
    _token = akun.token;
    _namaUser = akun.nama;
    _email = akun.email;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kToken, akun.token);
      await prefs.setString(_kNama, akun.nama);
      await prefs.setString(_kEmail, akun.email);
    } catch (_) {
      // Sesi tetap aktif di memori meski gagal disimpan.
    }
    notifyListeners();
  }

  /// Logout: hapus token di server (jika terjangkau) dan sesi lokal.
  Future<void> logout() async {
    try {
      await AuthPhpApi.logout();
    } catch (_) {
      // Server tidak terjangkau: sesi lokal tetap dihapus.
    }
    _token = null;
    _namaUser = null;
    _email = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kToken);
      await prefs.remove(_kNama);
      await prefs.remove(_kEmail);
    } catch (_) {}
    notifyListeners();
  }
}
