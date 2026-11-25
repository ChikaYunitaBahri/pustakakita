import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/buku.dart';

class BukuException implements Exception {
  final String pesan;
  BukuException(this.pesan);

  @override
  String toString() => pesan;
}

class BukuService {
  Future<List<Buku>> ambilBuku(String kataKunci) async {
    final uri = Uri.https('www.googleapis.com', '/books/v1/volumes', {
      'q': kataKunci,
      'maxResults': '20',
    });

    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 10));

      if (res.statusCode != 200) {
        throw BukuException('Server mengembalikan status ${res.statusCode}.');
      }

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final items = (body['items'] as List?) ?? [];

      if (items.isEmpty) {
        throw BukuException('Data buku kosong.');
      }

      return items
          .map((e) => Buku.fromJson(e as Map<String, dynamic>))
          .toList();
    } on BukuException {
      rethrow;
    } on TimeoutException {
      throw BukuException('Koneksi terlalu lama (timeout). Coba lagi.');
    } on FormatException {
      throw BukuException('Format data dari server tidak valid.');
    } catch (_) {
      throw BukuException('Tidak bisa terhubung ke internet.');
    }
  }
}