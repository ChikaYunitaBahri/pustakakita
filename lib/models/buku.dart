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

  factory Buku.fromJson(Map<String, dynamic> json) {
    final v = (json['volumeInfo'] ?? {}) as Map<String, dynamic>;
    final penulis = v['authors'] as List?;
    final kategori = v['categories'] as List?;
    return Buku(
      id: (json['id'] ?? '').toString(),
      judul: (v['title'] ?? 'Tanpa judul').toString(),
      penulis: penulis == null ? 'Penulis tidak diketahui' : penulis.join(', '),
      kategori: kategori == null ? 'Umum' : kategori.first.toString(),
      gambar: (v['imageLinks']?['thumbnail'])?.toString(),
    );
  }
}