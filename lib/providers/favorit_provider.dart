import 'package:flutter/foundation.dart';
import '../models/buku.dart';

class FavoritProvider extends ChangeNotifier {
  final dynamic _box;
  FavoritProvider(this._box);

  List<String> get ids => _box.keys.map((e) => e.toString()).toList();
  bool isFavorit(Buku buku) => _box.containsKey(buku.id);

  Future<void> toggle(Buku buku) async {
    if (isFavorit(buku)) {
      await _box.delete(buku.id);
    } else {
      await _box.put(buku.id, {
        'id': buku.id, 'judul': buku.judul, 'penulis': buku.penulis,
        'kategori': buku.kategori, 'gambar': buku.gambar,
      });
    }
    notifyListeners();
  }

  List<Buku> get semua => _box.values.map((v) => Buku(
    id: v['id'] as String, judul: v['judul'] as String,
    penulis: v['penulis'] as String, kategori: v['kategori'] as String,
    gambar: v['gambar'] as String?,
  )).toList();
}
