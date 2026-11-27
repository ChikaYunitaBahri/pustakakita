
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

  // ==================================================
  // MEMINJAM BUKU
  // ==================================================
  Future<bool> pinjam(Buku b) async {
    try {
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

      // 1. Simpan peminjaman ke database.
      final idPeminjaman = await _db.tambah(peminjamanBaru);

      // 2. Simpan notifikasi peminjaman ke inbox.
      await _notifikasi.simpanInbox(
        id: 'pinjam-$idPeminjaman',
        judul: 'Peminjaman Berhasil',
        isi: 'Kamu berhasil meminjam buku "${b.judul}".',
        tipe: 'peminjaman',
      );

      // 3. Tampilkan notifikasi Android.
      await _notifikasi.tampilkan(
        id: 1000000 + idPeminjaman,
        judul: 'Peminjaman Berhasil',
        isi: 'Kamu berhasil meminjam buku "${b.judul}".',
      );

      // 4. Siapkan pengingat H-1.
      final waktuPengingat = peminjamanBaru.tglJatuhTempo
          .subtract(const Duration(days: 1));

      final judulPengingat = 'Pengingat Pengembalian Buku';
      final isiPengingat =
          'Buku "${b.judul}" akan jatuh tempo besok. '
          'Jangan lupa dikembalikan!';

      await _notifikasi.simpanInbox(
        id: 'pengingat-$idPeminjaman',
        judul: judulPengingat,
        isi: isiPengingat,
        tipe: 'pengingat',
        waktu: waktuPengingat,
      );

      await _notifikasi.jadwalkan(
        id: idPeminjaman,
        judul: judulPengingat,
        isi: isiPengingat,
        waktu: waktuPengingat,
      );

      // 5. Muat ulang data.
      await muat();
      return true;
    } catch (e) {
      _error = 'Gagal meminjam buku.';
      notifyListeners();
      return false;
    }
  }

  // ==================================================
  // MENGEMBALIKAN BUKU
  // ==================================================
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

      // 1. Update status peminjaman.
      await _db.ubah(p.id!, {
        'status': 'kembali',
        'tgl_kembali': DateTime.now().toIso8601String(),
      });

      // 2. Batalkan pengingat Android.
      await _notifikasi.batalkan(p.id!);

      // 3. Hapus inbox pengingat jatuh tempo.
      await _notifikasi.hapusInbox('pengingat-${p.id}');

      // 4. Simpan pemberitahuan pengembalian.
      await _notifikasi.simpanInbox(
        id: 'kembali-${p.id}',
        judul: 'Buku Berhasil Dikembalikan',
        isi: 'Buku "${p.judul}" telah berhasil dikembalikan.',
        tipe: 'pengembalian',
      );

      // 5. Muat ulang data.
      await muat();
      return true;
    } catch (e) {
      _error = 'Gagal mengembalikan buku.';
      notifyListeners();
      return false;
    }
  }

  // ==================================================
  // MEMPERPANJANG MASA PEMINJAMAN
  // ==================================================
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

      final dasar = p.tglJatuhTempo.isAfter(sekarang)
          ? p.tglJatuhTempo
          : sekarang;

      final jatuhTempoBaru = dasar.add(const Duration(days: 7));

      // 1. Update tanggal jatuh tempo di database.
      await _db.ubah(p.id!, {
        'tgl_jatuh_tempo': jatuhTempoBaru.toIso8601String(),
      });

      // 2. Batalkan pengingat lama.
      await _notifikasi.batalkan(p.id!);

      // 3. Hapus inbox pengingat lama.
      await _notifikasi.hapusInbox('pengingat-${p.id}');

      // 4. Jadwalkan pengingat baru H-1.
      final waktuPengingat = jatuhTempoBaru
          .subtract(const Duration(days: 1));

      final judulPengingat = 'Pengingat Pengembalian Buku';
      final isiPengingat =
          'Buku "${p.judul}" akan jatuh tempo besok. '
          'Jangan lupa dikembalikan!';

      await _notifikasi.simpanInbox(
        id: 'pengingat-${p.id}',
        judul: judulPengingat,
        isi: isiPengingat,
        tipe: 'pengingat',
        waktu: waktuPengingat,
      );

      await _notifikasi.jadwalkan(
        id: p.id!,
        judul: judulPengingat,
        isi: isiPengingat,
        waktu: waktuPengingat,
      );

      // 5. Simpan notifikasi perpanjangan.
      await _notifikasi.simpanInbox(
        id: 'perpanjang-${p.id}-${jatuhTempoBaru.millisecondsSinceEpoch}',
        judul: 'Peminjaman Berhasil Diperpanjang',
        isi: 'Masa peminjaman buku "${p.judul}" '
            'diperpanjang hingga ${jatuhTempoBaru.day}/'
            '${jatuhTempoBaru.month}/${jatuhTempoBaru.year}.',
        tipe: 'perpanjangan',
      );

      // 6. Muat ulang data.
      await muat();
      return true;
    } catch (e) {
      _error = 'Gagal memperpanjang masa peminjaman.';
      notifyListeners();
      return false;
    }
  }

  // ==================================================
  // MENGHAPUS DATA PEMINJAMAN
  // ==================================================
  Future<bool> hapus(Peminjaman p) async {
    try {
      if (p.id == null) {
        _error = 'ID peminjaman tidak ditemukan.';
        notifyListeners();
        return false;
      }

      // 1. Batalkan pengingat.
      await _notifikasi.batalkan(p.id!);

      // 2. Hapus notifikasi terkait peminjaman ini.
      await _notifikasi.hapusInbox('pinjam-${p.id}');
      await _notifikasi.hapusInbox('pengingat-${p.id}');
      await _notifikasi.hapusInbox('kembali-${p.id}');

      final inbox = await _notifikasi.ambilInbox();
      for (final n in inbox) {
        if (n.id.startsWith('perpanjang-${p.id}-')) {
          await _notifikasi.hapusInbox(n.id);
        }
      }

      // 3. Hapus data peminjaman dari database.
      await _db.hapus(p.id!);

      // 4. Muat ulang data.
      await muat();
      return true;
    } catch (e) {
      _error = 'Gagal menghapus riwayat peminjaman.';
      notifyListeners();
      return false;
    }
  }
}
