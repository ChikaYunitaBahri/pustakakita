import 'dart:convert';

class Notifikasi {
  const Notifikasi({
    required this.id,
    required this.judul,
    required this.isi,
    required this.waktu,
    this.dibaca = false,
    this.tipe = 'umum',
  });

  final String id;
  final String judul;
  final String isi;
  final DateTime waktu;
  final bool dibaca;
  final String tipe;

  // Mengubah notifikasi menjadi Map untuk penyimpanan.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'judul': judul,
      'isi': isi,
      'waktu': waktu.toIso8601String(),
      'dibaca': dibaca,
      'tipe': tipe,
    };
  }

  // Mengubah Map menjadi objek Notifikasi.
  factory Notifikasi.fromMap(Map<String, dynamic> map) {
    return Notifikasi(
      id: map['id'].toString(),
      judul: map['judul'] ?? '',
      isi: map['isi'] ?? '',
      waktu: DateTime.tryParse(map['waktu'] ?? '') ?? DateTime.now(),
      dibaca: map['dibaca'] == true,
      tipe: map['tipe'] ?? 'umum',
    );
  }

  // Mengubah objek menjadi JSON.
  String toJson() => jsonEncode(toMap());

  // Membaca objek dari JSON.
  factory Notifikasi.fromJson(String source) {
    return Notifikasi.fromMap(jsonDecode(source));
  }

  // Membuat salinan objek dengan perubahan tertentu.
  Notifikasi copyWith({
    String? id,
    String? judul,
    String? isi,
    DateTime? waktu,
    bool? dibaca,
    String? tipe,
  }) {
    return Notifikasi(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      isi: isi ?? this.isi,
      waktu: waktu ?? this.waktu,
      dibaca: dibaca ?? this.dibaca,
      tipe: tipe ?? this.tipe,
    );
  }
}