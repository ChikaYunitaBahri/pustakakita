import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../models/buku.dart';

/// Menyimpan daftar buku favorit di Hive.
/// Buku disimpan sebagai Map (lewat Buku.toMap) dengan id buku sebagai key.
class FavoritProvider extends ChangeNotifier {
  final dynamic _box;

  FavoritProvider(this._box);

  List<String> get ids => _box.keys.map((key) => key.toString()).toList();

  bool isFavorit(Buku buku) => _box.containsKey(buku.id);

  Future<void> toggle(Buku buku) async {
    if (isFavorit(buku)) {
      await _box.delete(buku.id);
    } else {
      await _box.put(buku.id, buku.toMap());
    }

    notifyListeners();
  }

  /// Semua buku favorit. Data di Hive berupa Map, jadi diubah kembali
  /// menjadi objek Buku. Dipakai oleh halaman Favorit dan badge di tab.
  List<Buku> get semua => _box.values
      .whereType<Map>()
      .map((m) => Buku.fromMap(m))
      .toList();
}