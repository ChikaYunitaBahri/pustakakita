import 'package:flutter/foundation.dart';

import '../models/buku.dart';

class PeminjamanProvider extends ChangeNotifier {
  final List<Buku> _dipinjam = [];

  List<Buku> get dipinjam => List.unmodifiable(_dipinjam);
  int get jumlah => _dipinjam.length;

  bool sudahDipinjam(Buku b) => _dipinjam.any((x) => x.id == b.id);

  void pinjam(Buku b) {
    if (!sudahDipinjam(b)) {
      _dipinjam.add(b);
      notifyListeners(); // kabari semua halaman: data berubah
    }
  }

  void kembalikan(Buku b) {
    _dipinjam.removeWhere((x) => x.id == b.id);
    notifyListeners();
  }
}