/// Aturan validasi form login. Dipisah dari layar agar bisa diuji sebagai unit.
class Validator {
  static final _polaEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// Mengembalikan pesan error, atau null jika email valid.
  static String? email(String? v) {
    final teks = v?.trim() ?? '';
    if (teks.isEmpty) return 'Email wajib diisi';
    if (!_polaEmail.hasMatch(teks)) return 'Format email tidak valid';
    return null;
  }

  /// Mengembalikan pesan error, atau null jika password terisi.
  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password wajib diisi';
    return null;
  }
}
