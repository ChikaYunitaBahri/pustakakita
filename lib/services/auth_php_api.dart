import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

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

/// Autentikasi memakai Firebase Authentication.
/// Nama kelas dipertahankan agar halaman yang sudah ada tetap berjalan.
class AuthPhpApi {
  /// Masih disediakan untuk fitur lain yang belum dipindahkan dari PHP.
  static String get baseUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2/pustakakita_api';
    }
    return 'http://localhost/pustakakita_api';
  }

  static AkunPhp? akun;

  static FirebaseAuth get _auth => FirebaseAuth.instance;

  static Future<void> register(
      String nama, String email, String password) async {
    try {
      final hasil = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await hasil.user?.updateDisplayName(nama.trim());
      // Setelah daftar, pengguna login sendiri seperti versi sebelumnya.
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthPhpException(_pesanError(e));
    }
  }

  static Future<AkunPhp> login(String email, String password) async {
    try {
      final hasil = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      akun = await _akunDari(hasil.user!);
      return akun!;
    } on FirebaseAuthException catch (e) {
      throw AuthPhpException(_pesanError(e));
    }
  }

  /// Memulihkan sesi yang disimpan otomatis oleh Firebase.
  static Future<AkunPhp?> pulihkan() async {
    final user = await _auth.authStateChanges().first;
    akun = user == null ? null : await _akunDari(user);
    return akun;
  }

  static Future<void> logout() async {
    await _auth.signOut();
    akun = null;
  }

  static Future<AkunPhp> _akunDari(User user) async {
    var token = '';
    try {
      token = await user.getIdToken() ?? '';
    } catch (_) {
      // Token gagal diambil, misalnya saat tidak ada internet.
    }
    final email = user.email ?? '';
    final nama = user.displayName;
    return AkunPhp(
      nama: nama == null || nama.isEmpty ? email.split('@').first : nama,
      email: email,
      token: token,
    );
  }

  static String _pesanError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
        return 'Email atau password salah.';
      case 'email-already-in-use':
        return 'Email sudah terdaftar.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'weak-password':
        return 'Password terlalu lemah. Gunakan minimal 6 karakter.';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      case 'operation-not-allowed':
        return 'Login Email/Password belum diaktifkan di Firebase.';
      default:
        return e.message ?? 'Terjadi kesalahan (${e.code}).';
    }
  }
}