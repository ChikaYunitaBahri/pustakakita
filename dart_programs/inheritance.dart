class Buku {
  final String judul;
  final String penulis;
  Buku(this.judul, this.penulis);

  String info() => '$judul oleh $penulis';
}

class BukuDigital extends Buku {
  final double ukuranMb;
  BukuDigital(super.judul, super.penulis, this.ukuranMb);

  @override
  String info() => '${super.info()} (e-book, $ukuranMb MB)';
}

void main() {
  final daftar = [
    Buku('Laskar Pelangi', 'Andrea Hirata'),
    BukuDigital('Dart Dasar', 'Tim PustakaKita', 4.2),
  ];
  for (final b in daftar) {
    print(b.info());
  }
}