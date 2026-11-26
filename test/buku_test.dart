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
}