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

  Map<String, dynamic> toMap() => {
    'id': id,
    'judul': judul,
    'penulis': penulis,
    'kategori': kategori,
    'gambar': gambar,
  };

  factory Buku.fromMap(Map<dynamic, dynamic> map) {
    return Buku(
      id: map['id'] as String,
      judul: map['judul'] as String,
      penulis: map['penulis'] as String,
      kategori: map['kategori'] as String,
      gambar: map['gambar'] as String?,
    );
  }
}
