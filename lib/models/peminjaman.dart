class Peminjaman {
  final int? id;
  final int userId;
  final String bookId, judul, penulis, kategori;
  final String? gambar;
  final DateTime tglPinjam, tglJatuhTempo;
  final DateTime? tglKembali;
  final String status;
 
  Peminjaman({
    this.id,
    this.userId = 0,
    required this.bookId,
    required this.judul,
    required this.penulis,
    required this.kategori,
    this.gambar,
    required this.tglPinjam,
    required this.tglJatuhTempo,
    this.tglKembali,
    this.status = 'dipinjam',
  });
 
  bool get aktif => status == 'dipinjam';
 
  Map<String, Object?> toMap() => {
    'id': id, 'user_id': userId, 'book_id': bookId,
    'judul': judul, 'penulis': penulis, 'kategori': kategori,
    'gambar': gambar,
    'tgl_pinjam': tglPinjam.toIso8601String(),
    'tgl_jatuh_tempo': tglJatuhTempo.toIso8601String(),
    'tgl_kembali': tglKembali?.toIso8601String(),
    'status': status,
  };
 
  factory Peminjaman.fromMap(Map<String, Object?> m) {
    final kembali = m['tgl_kembali'] as String?;
    return Peminjaman(
      id: m['id'] as int?,
      userId: (m['user_id'] as int?) ?? 0,
      bookId: m['book_id'] as String,
      judul: m['judul'] as String,
      penulis: m['penulis'] as String,
      kategori: m['kategori'] as String,
      gambar: m['gambar'] as String?,
      tglPinjam: DateTime.parse(m['tgl_pinjam'] as String),
      tglJatuhTempo: DateTime.parse(m['tgl_jatuh_tempo'] as String),
      tglKembali: kembali == null ? null : DateTime.parse(kembali),
      status: m['status'] as String,
    );
  }
}