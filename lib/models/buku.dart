
class Buku {
  const Buku({
    required this.id,
    required this.judul,
    required this.penulis,
    required this.kategori,
    this.gambar,
  });

  final String id;
  final String judul;
  final String penulis;
  final String kategori;
  final String? gambar;

  // Mengubah data buku menjadi Map untuk penyimpanan favorit.
  Map<String, dynamic> toMap() => {
        'id': id,
        'judul': judul,
        'penulis': penulis,
        'kategori': kategori,
        'gambar': gambar,
      };

  // Mengambil data buku dari Map.
  factory Buku.fromMap(Map<dynamic, dynamic> map) {
    return Buku(
      id: map['id'] as String,
      judul: map['judul'] as String,
      penulis: map['penulis'] as String,
      kategori: map['kategori'] as String,
      gambar: map['gambar'] as String?,
    );
  }

  // Mengambil data buku dari Google Books API.
  factory Buku.fromJson(Map<String, dynamic> json, {String? kategori}) {
    final v = Map<String, dynamic>.from(
      (json['volumeInfo'] as Map?) ?? <String, dynamic>{},
    );

    final penulis = v['authors'] as List?;
    final kategoriApi = v['categories'] as List?;

    return Buku(
      id: (json['id'] ?? '').toString(),
      judul: (v['title'] ?? 'Tanpa judul').toString(),
      penulis: (penulis == null || penulis.isEmpty)
          ? 'Penulis tidak diketahui'
          : penulis.join(', '),
      kategori: kategori ??
          ((kategoriApi == null || kategoriApi.isEmpty)
              ? 'Umum'
              : kategoriApi.first.toString()),
      gambar: ((v['imageLinks'] as Map?)?['thumbnail'])?.toString(),
    );
  }

  // Mengambil data buku dari Open Library API.
  factory Buku.fromOpenLibrary(
    Map<String, dynamic> json, {
    String? kategori,
  }) {
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
