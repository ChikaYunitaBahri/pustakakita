import 'package:flutter/foundation.dart';

import '../services/auth_php_api.dart';

/// Menyimpan sesi login. Sesi disimpan otomatis oleh Firebase.
class AuthProvider extends ChangeNotifier {
  String? _namaUser;
  String? _email;
  String? _token;
  bool _siap = false;

  String? get namaUser => _namaUser;
  String? get email => _email;
  String? get token => _token;

  /// true setelah sesi selesai diperiksa.
  bool get siap => _siap;
  bool get sudahLogin => _token != null;

  /// Dipanggil sekali saat aplikasi dibuka.
  Future<void> muat() async {
    try {
      _isi(await AuthPhpApi.pulihkan());
    } catch (_) {
      // Jika sesi gagal dibaca, anggap belum login.
    }
    _siap = true;
    notifyListeners();
  }

  /// Melempar [AuthPhpException] jika login gagal.
  Future<void> login(String email, String password) async {
    _isi(await AuthPhpApi.login(email, password));
    notifyListeners();
  }

  Future<void> logout() async {
    await AuthPhpApi.logout();
    _isi(null);
    notifyListeners();
  }

  void _isi(AkunPhp? akun) {
    _namaUser = akun?.nama;
    _email = akun?.email;
    _token = akun?.token;
  }
}