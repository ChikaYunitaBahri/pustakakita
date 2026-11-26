// ignore_for_file: avoid_print
String? cariBuku(List<String> daftar, String kata) {
  for (final judul in daftar) {
    if (judul.toLowerCase().contains(kata.toLowerCase())) {
      return judul;
    }
  }
  return null; // tidak ketemu
}

void main() {
  final daftar = ['Flutter Dasar', 'Basis Data', 'Laskar Pelangi'];

  final hasil1 = cariBuku(daftar, 'flutter');
  print(hasil1 ?? 'Buku tidak ditemukan');

  final hasil2 = cariBuku(daftar, 'xyz');
  print(hasil2 ?? 'Buku tidak ditemukan');
  print(hasil2?.length ?? 0);
}