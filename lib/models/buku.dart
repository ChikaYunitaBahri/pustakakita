class Buku {
  final String id;
  final String judul;
  final String penulis;
  final String kategori;
  final String? gambar;

  Buku({
    required this.id,
    required this.judul,
    required this.penulis,
    required this.kategori,
    this.gambar,
  });

  factory Buku.fromJson(Map<String, dynamic> json, {String? kategori}) {
    final v = (json['volumeInfo'] ?? {}) as Map<String, dynamic>;
    final penulis = v['authors'] as List?;
    final kategoriApi = v['categories'] as List?;
    return Buku(
      id: (json['id'] ?? '').toString(),
      judul: (v['title'] ?? 'Tanpa judul').toString(),
      penulis: penulis == null ? 'Penulis tidak diketahui' : penulis.join(', '),
      kategori: kategori ??
          (kategoriApi == null ? 'Umum' : kategoriApi.first.toString()),
      gambar: (v['imageLinks']?['thumbnail'])?.toString(),
    );
  }

    factory Buku.fromOpenLibrary(Map<String, dynamic> json, {String? kategori}) {
    final penulis = json['author_name'] as List?;
    final coverId = json['cover_i'];
    final key = (json['key'] ?? '').toString();
    return Buku(
      id: key.replaceAll('/works/', ''),
      judul: (json['title'] ?? 'Tanpa judul').toString(),
      penulis: (penulis == null || penulis.isEmpty)
          ? 'Penulis tidak diketahui'
          : penulis.take(2).join(', '),
      kategori: kategori ?? 'Umum',
      gambar: coverId == null
          ? null
          : 'https://covers.openlibrary.org/b/id/$coverId-M.jpg',
    );
  }
}