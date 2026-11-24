void main() {
  final perKategori = <String, List<String>>{
    'Novel': ['Laskar Pelangi', 'Bumi Manusia'],
    'Teknologi': ['Flutter Dasar', 'Basis Data'],
  };

  perKategori['Sains'] = ['Fisika Dasar'];
  perKategori['Novel']!.add('Negeri 5 Menara');

  perKategori.forEach((kategori, daftar) {
    print('$kategori: ${daftar.join(', ')}');
  });
  print('Jumlah kategori: ${perKategori.length}');
}