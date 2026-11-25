import 'package:flutter/foundation.dart';

import '../models/buku.dart';
import '../services/buku_service.dart';

class BukuProvider extends ChangeNotifier {
  final BukuService _service;

  BukuProvider({BukuService? service}) : _service = service ?? BukuService();

  bool _loading = false;
  String? _error;
  List<Buku> _data = [];

  bool get loading => _loading;
  String? get error => _error;
  List<Buku> get data => List.unmodifiable(_data);

  Future<void> muat([String kataKunci = 'pemrograman']) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _data = await _service.ambilBuku(kataKunci);
    } on BukuException catch (e) {
      _error = e.pesan;
      _data = [];
    } catch (_) {
      _error = 'Terjadi kesalahan tak terduga.';
      _data = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}