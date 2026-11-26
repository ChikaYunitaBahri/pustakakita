import 'package:flutter/foundation.dart';
import '../models/buku.dart';

class FavoritProvider extends ChangeNotifier {
  final dynamic _box;

  FavoritProvider(this._box);

  List<String> get ids => _box.keys.map((key) => key.toString()).toList();

  bool isFavorit(Buku buku) => _box.containsKey(buku.id);

  Future<void> toggle(Buku buku) async {
    if (isFavorit(buku)) {
      await _box.delete(buku.id);
    } else {
      await _box.put(buku.id, buku);
    }
    notifyListeners();
  }

  List<Buku> get semua => _box.values.whereType<Buku>().toList();
}
