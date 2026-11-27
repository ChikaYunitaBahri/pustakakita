import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AuthPhpException implements Exception {
  final String pesan;
  AuthPhpException(this.pesan);

  @override
  String toString() => pesan;
}

class AkunPhp {
  final String nama;
  final String email;
  final String token;

  AkunPhp({required this.nama, required this.email, required this.token});
}

/// Memanggil backend PHP: register.php, login.php, logout.php.
/// Format balasan backend: { "sukses": bool, "pesan": "...", "data": {...} }
class AuthPhpApi {
  /// Chrome/Windows memakai localhost. Emulator Android memakai 10.0.2.2.
  /// Sesuaikan nama folder jika backend ditaruh di folder lain pada htdocs.
  static String get baseUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2/pustakakita_api';
    }
    return 'http://localhost/pustakakita_api';
  }

  static AkunPhp? akun;

  static Future<Map<String, dynamic>> _post(
    String file,
    Map<String, dynamic> body,
  ) async {
    http.Response res;
    try {
      res = await http
          .post(
            Uri.parse('$baseUrl/$file'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      throw AuthPhpException(
        'Tidak dapat terhubung ke server. Pastikan Apache dan MySQL di XAMPP menyala.',
      );
    }

    Map<String, dynamic> data;
    try {
      data = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      throw AuthPhpException(
        'Balasan server tidak dikenali (kode ${res.statusCode}). '
        'Periksa alamat backend: $baseUrl/$file',
      );
    }

    if (data['sukses'] == true) return data;
    throw AuthPhpException(
      (data['pesan'] ?? 'Terjadi kesalahan (${res.statusCode})').toString(),
    );
  }

  static Future<void> register(
      String nama, String email, String password) async {
    await _post('register.php',
        {'nama': nama, 'email': email, 'password': password});
  }

  static Future<AkunPhp> login(String email, String password) async {
    final data =
        await _post('login.php', {'email': email, 'password': password});
    final isi = data['data'] as Map<String, dynamic>;
    akun = AkunPhp(
      nama: isi['nama'].toString(),
      email: isi['email'].toString(),
      token: isi['token'].toString(),
    );
    return akun!;
  }

  static Future<void> logout() async {
    final token = akun?.token;
    try {
      if (token != null) await _post('logout.php', {'token': token});
    } finally {
      akun = null;
    }
  }
}
