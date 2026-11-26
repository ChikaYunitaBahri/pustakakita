import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  String? _namaUser;

  String? get namaUser => _namaUser;
  bool get sudahLogin => _namaUser != null;

  void setSesi(String nama) {
    _namaUser = nama;
    notifyListeners();
  }

  void logout() {
    _namaUser = null;
    notifyListeners();
  }
}