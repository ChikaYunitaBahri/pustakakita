
import 'package:flutter/foundation.dart';

import '../data/db_helper.dart';
import '../models/buku.dart';
import '../models/peminjaman.dart';
import '../services/notifikasi_service.dart';

class PeminjamanProvider extends ChangeNotifier {
  PeminjamanProvider({DbHelper? db}) : _db = db ?? DbHelper.instance;

  final DbHelper _db;
  final NotifikasiService _notifikasi = NotifikasiService.instance;

  List<Peminjaman> _semua = [];

  bool _siap = false;
  String? _error;

  // Getter utama
  bool get siap => _siap;
  String? get error => _error;

  // Daftar peminjaman aktif
  List<Peminjaman> get aktif =>
      _semua.where((p) => p.aktif).toList();

  // Daftar riwayat peminjaman
  List<Peminjaman> get riwayat =>
      _semua.where((p) => !p.aktif).toList();

  // Kompatibilitas dengan halaman lama
  List<Peminjaman> get dipinjam => aktif;
  int get jumlah => aktif.length;

  // Mengecek apakah buku sedang dipinjam
  bool sudahDipinjam(Buku b) {
    return _semua.any(
      (p) => p.bookId == b.id && p.aktif,
    );
  }

  // Memuat data dari database
  Future<void> muat() async {
    try {
      _semua = await _db.semua();
      _error = null;
    } catch (e) {
      _error = 'Gagal membaca data peminjaman.';
    }

    _siap = true;
    notifyListeners();
  }

  // Meminjam buku
  Future<bool> pinjam(Buku b) async {
    try {
      // Mencegah buku yang sama dipinjam dua kali
      if (sudahDipinjam(b)) {
        _error = 'Buku ini masih dipinjam.';
        notifyListeners();
        return false;
      }

      final sekarang = DateTime.now();

      final peminjamanBaru = Peminjaman(
        bookId: b.id,
        judul: b.judul,
        penulis: b.penulis,
        kategori: b.kategori,
        gambar: b.gambar,
        tglPinjam: sekarang,
        tglJatuhTempo: sekarang.add(const Duration(days: 7)),
        status: 'dipinjam',
      );

      // 1. Simpan peminjaman ke database
      final idPeminjaman = await _db.tambah(peminjamanBaru);

      // 2. Tampilkan notifikasi konfirmasi
      await _notifikasi.tampilkan(
        id: 1000000 + idPeminjaman,
        judul: 'Peminjaman Berhasil',
        isi: 'Kamu berhasil meminjam buku "${b.judul}".',
      );

      // 3. Jadwalkan pengingat satu hari sebelum jatuh tempo
      await _notifikasi.jadwalkan(
        id: idPeminjaman,
        judul: 'Pengingat Pengembalian Buku',
        isi:
            'Buku "${b.judul}" akan jatuh tempo besok. Jangan lupa dikembalikan!',
        waktu: peminjamanBaru.tglJatuhTempo
            .subtract(const Duration(days: 1)),
      );

      // 4. Muat ulang data
      await muat();
      return true;
    } catch (e) {
      _error = 'Gagal meminjam buku.';
      notifyListeners();
      return false;
    }
  }

  // Mengembalikan buku
  Future<bool> kembalikan(Peminjaman p) async {
    try {
      if (p.id == null) {
        _error = 'ID peminjaman tidak ditemukan.';
        notifyListeners();
        return false;
      }

      if (!p.aktif) {
        _error = 'Buku sudah dikembalikan.';
        notifyListeners();
        return false;
      }

      // 1. Update status peminjaman di database
      await _db.ubah(p.id!, {
        'status': 'kembali',
        'tgl_kembali': DateTime.now().toIso8601String(),
      });

      // 2. Batalkan pengingat jatuh tempo
      await _notifikasi.batalkan(p.id!);

      // 3. Muat ulang data
      await muat();
      return true;
    } catch (e) {
      _error = 'Gagal mengembalikan buku.';
      notifyListeners();
      return false;
    }
  }

  // Memperpanjang masa peminjaman selama 7 hari
  Future<bool> perpanjang(Peminjaman p) async {
    try {
      if (p.id == null) {
        _error = 'ID peminjaman tidak ditemukan.';
        notifyListeners();
        return false;
      }

      if (!p.aktif) {
        _error = 'Buku sudah dikembalikan.';
        notifyListeners();
        return false;
      }

      final sekarang = DateTime.now();

      // Jika belum terlambat, tambah 7 hari dari tanggal jatuh tempo.
      // Jika sudah terlambat, tambah 7 hari dari hari ini.
      final dasar = p.tglJatuhTempo.isAfter(sekarang)
          ? p.tglJatuhTempo
          : sekarang;

      final jatuhTempoBaru = dasar.add(const Duration(days: 7));

      // 1. Update tanggal jatuh tempo di database
      await _db.ubah(p.id!, {
        'tgl_jatuh_tempo': jatuhTempoBaru.toIso8601String(),
      });

      // 2. Batalkan pengingat lama
      await _notifikasi.batalkan(p.id!);

      // 3. Jadwalkan pengingat baru H-1
      await _notifikasi.jadwalkan(
        id: p.id!,
        judul: 'Pengingat Pengembalian Buku',
        isi:
            'Buku "${p.judul}" akan jatuh tempo besok. Jangan lupa dikembalikan!',
        waktu: jatuhTempoBaru.subtract(const Duration(days: 1)),
      );

      // 4. Muat ulang data
      await muat();
      return true;
    } catch (e) {
      _error = 'Gagal memperpanjang masa peminjaman.';
      notifyListeners();
      return false;
    }
  }

  // Menghapus data peminjaman / riwayat
  Future<bool> hapus(Peminjaman p) async {
    try {
      if (p.id == null) {
        _error = 'ID peminjaman tidak ditemukan.';
        notifyListeners();
        return false;
      }

      // 1. Batalkan pengingat jika masih ada
      await _notifikasi.batalkan(p.id!);

      // 2. Hapus data dari database
      await _db.hapus(p.id!);

      // 3. Muat ulang data
      await muat();
      return true;
    } catch (e) {
      _error = 'Gagal menghapus riwayat peminjaman.';
      notifyListeners();
      return false;
    }
  }
}
