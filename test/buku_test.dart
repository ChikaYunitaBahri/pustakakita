import 'package:flutter_test/flutter_test.dart';
import 'package:pustakakita/models/buku.dart';

void main() {
  test('fromJson memetakan field dengan benar', () {
    final json = {
      'id': '1',
      'volumeInfo': {
        'title': 'Flutter',
        'authors': ['A', 'B'],
        'categories': ['Teknologi'],
      },
    };
    final b = Buku.fromJson(json);
    expect(b.judul, 'Flutter');
    expect(b.penulis, 'A, B');
    expect(b.kategori, 'Teknologi');
  });

  test('field kosong memakai nilai default', () {
    final b = Buku.fromJson({'id': '2'});
    expect(b.judul, 'Tanpa judul');
    expect(b.penulis, 'Penulis tidak diketahui');
    expect(b.kategori, 'Umum');
  });

  test('kategori dari luar menimpa kategori API', () {
    final b = Buku.fromJson({'id': '3'}, kategori: 'Novel');
    expect(b.kategori, 'Novel');
  });

  group('Buku.fromOpenLibrary (format Open Library)', () {
    test('memetakan field dengan benar', () {
      final json = {
        'key': '/works/OL123W',
        'title': 'Clean Code',
        'author_name': ['Robert C. Martin'],
        'cover_i': 12345,
      };
      final b = Buku.fromOpenLibrary(json, kategori: 'Teknologi');
      expect(b.id, 'OL123W');
      expect(b.judul, 'Clean Code');
      expect(b.penulis, 'Robert C. Martin');
      expect(b.kategori, 'Teknologi');
      expect(b.gambar, 'https://covers.openlibrary.org/b/id/12345-M.jpg');
    });

    test('field kosong memakai nilai default', () {
      final b = Buku.fromOpenLibrary({'key': '/works/OL1W'});
      expect(b.judul, 'Tanpa judul');
      expect(b.penulis, 'Penulis tidak diketahui');
      expect(b.kategori, 'Umum');
      expect(b.gambar, isNull);
    });

    test('hanya mengambil dua penulis pertama', () {
      final b = Buku.fromOpenLibrary({
        'key': '/works/OL2W',
        'author_name': ['A', 'B', 'C'],
      });
      expect(b.penulis, 'A, B');
    });
  });
}