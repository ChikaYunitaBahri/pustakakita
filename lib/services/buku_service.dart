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
  // Label kategori (tampil di aplikasi) -> query pencarian Open Library
  static const Map<String, String> kategoriQuery = {
    'Teknologi': 'subject:programming',
    'Novel': 'subject:fiction',
    'Sains': 'subject:science',
    'Bisnis': 'subject:business',
    'Sejarah': 'subject:history',
    'Pendidikan': 'subject:education',
  };

  Future<List<Buku>> ambilBuku(
    String kataKunci, {
    String? kategori,
    int maxResults = 20,
  }) async {
    final uri = Uri.https('openlibrary.org', '/search.json', {
      'q': kataKunci,
      'limit': '$maxResults',
      'fields': 'key,title,author_name,cover_i',
    });

    try {
      final res = await http.get(uri, headers: {
        'User-Agent': 'PustakaKita/1.0 (tugas kuliah UNTAN)',
      }).timeout(const Duration(seconds: 15));

      if (res.statusCode == 429) {
        throw BukuException(
          'Batas permintaan tercapai (status 429). Coba lagi beberapa saat.',
        );
      }
      if (res.statusCode != 200) {
        throw BukuException('Server mengembalikan status ${res.statusCode}.');
      }

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final docs = (body['docs'] as List?) ?? [];

      if (docs.isEmpty) {
        throw BukuException('Data buku kosong.');
      }

      return docs
          .map((e) => Buku.fromOpenLibrary(
                e as Map<String, dynamic>,
                kategori: kategori,
              ))
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

  /// Mengambil buku dari beberapa kategori sekaligus, lalu menggabungkannya.
  Future<List<Buku>> ambilBukuBeragam({int perKategori = 8}) async {
    final errors = <BukuException>[];

    final hasil = await Future.wait(
      kategoriQuery.entries.map((e) async {
        try {
          return await ambilBuku(
            e.value,
            kategori: e.key,
            maxResults: perKategori,
          );
        } on BukuException catch (err) {
          errors.add(err);
          return <Buku>[];
        }
      }),
    );

    final semua = hasil.expand((x) => x).toList();

    // Kalau SEMUA kategori gagal, lempar error pertama
    if (semua.isEmpty) {
      throw errors.isNotEmpty ? errors.first : BukuException('Data buku kosong.');
    }

    // Buang buku ganda (id sama)
    final unik = <String, Buku>{};
    for (final b in semua) {
      unik.putIfAbsent(b.id, () => b);
    }
    return unik.values.toList();
  }
}