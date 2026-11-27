
import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../models/buku.dart';

class FavoritProvider extends ChangeNotifier {
  FavoritProvider(this._box);

  final Box _box;

  List<String> get ids =>
      _box.keys.map((key) => key.toString()).toList();

  bool isFavorit(Buku buku) => _box.containsKey(buku.id);

  Future<void> toggle(Buku buku) async {
    if (isFavorit(buku)) {
      await _box.delete(buku.id);
    } else {
      await _box.put(buku.id, buku.toMap());
    }

    notifyListeners();
  }

  List<Buku> get semua {
    return _box.values
        .whereType<Map>()
        .map((data) => Buku.fromMap(data))
        .toList();
  }
}
