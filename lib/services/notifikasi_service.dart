import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/notifikasi.dart';

class NotifikasiService {
  NotifikasiService._();

  static final NotifikasiService instance = NotifikasiService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const String _channelId = 'pustakakita_notifikasi';
  static const String _channelName = 'Notifikasi PustakaKita';
  static const String _channelDescription =
      'Notifikasi konfirmasi dan pengingat peminjaman buku';

  static const String _keyInbox = 'pustakakita_inbox_notifikasi';

  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
    _channelId,
    _channelName,
    channelDescription: _channelDescription,
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
  );

  // ==================================================
  // 1. INISIALISASI
  // ==================================================
  Future<void> init() async {
    if (_initialized) return;

    try {
      tzdata.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Pontianak'));

      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      );

      await _plugin.initialize(settings: settings);

      _initialized = true;
      debugPrint('NotifikasiService berhasil diinisialisasi.');
    } catch (e) {
      debugPrint('Error init NotifikasiService: $e');
    }
  }

  // ==================================================
  // 2. IZIN NOTIFIKASI
  // ==================================================
  Future<bool> izinAktif() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      debugPrint('Error memeriksa izin notifikasi: $e');
      return false;
    }
  }

  Future<bool> mintaIzin() async {
    try {
      final status = await Permission.notification.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Error meminta izin notifikasi: $e');
      return false;
    }
  }

  // ==================================================
  // 3. PENYIMPANAN INBOX NOTIFIKASI
  // ==================================================

  // Mengambil semua notifikasi dan mengurutkan terbaru di atas.
  Future<List<Notifikasi>> ambilInbox() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getStringList(_keyInbox) ?? [];

      final hasil = data
          .map((item) {
            try {
              return Notifikasi.fromJson(item);
            } catch (_) {
              return null;
            }
          })
          .whereType<Notifikasi>()
          .toList();

      hasil.sort((a, b) => b.waktu.compareTo(a.waktu));
      return hasil;
    } catch (e) {
      debugPrint('Error mengambil inbox: $e');
      return [];
    }
  }

  // Menyimpan notifikasi. ID yang sama akan diperbarui,
  // bukan ditambahkan sebagai duplikat.
  Future<void> simpanInbox({
    required String id,
    required String judul,
    required String isi,
    String tipe = 'umum',
    DateTime? waktu,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getStringList(_keyInbox) ?? [];

      data.removeWhere((item) {
        try {
          return Notifikasi.fromJson(item).id == id;
        } catch (_) {
          return false;
        }
      });

      final notifikasiBaru = Notifikasi(
        id: id,
        judul: judul,
        isi: isi,
        waktu: waktu ?? DateTime.now(),
        tipe: tipe,
      );

      data.add(notifikasiBaru.toJson());

      await prefs.setStringList(_keyInbox, data);
    } catch (e) {
      debugPrint('Error menyimpan inbox: $e');
    }
  }

  // Jumlah notifikasi yang belum dibaca.
  Future<int> jumlahBelumDibaca() async {
    final data = await ambilInbox();
    return data.where((n) => !n.dibaca).length;
  }

  // Menandai satu notifikasi sudah dibaca.
  Future<void> tandaiDibaca(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = await ambilInbox();

      final diperbarui = data.map((n) {
        if (n.id == id) {
          return n.copyWith(dibaca: true);
        }
        return n;
      }).toList();

      await prefs.setStringList(
        _keyInbox,
        diperbarui.map((n) => n.toJson()).toList(),
      );
    } catch (e) {
      debugPrint('Error menandai notifikasi dibaca: $e');
    }
  }

  // Menandai semua notifikasi sudah dibaca.
  Future<void> tandaiSemuaDibaca() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = await ambilInbox();

      final diperbarui = data.map((n) {
        return n.copyWith(dibaca: true);
      }).toList();

      await prefs.setStringList(
        _keyInbox,
        diperbarui.map((n) => n.toJson()).toList(),
      );
    } catch (e) {
      debugPrint('Error menandai semua notifikasi dibaca: $e');
    }
  }

  // Menghapus satu notifikasi dari inbox.
  Future<void> hapusInbox(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = await ambilInbox();

      data.removeWhere((n) => n.id == id);

      await prefs.setStringList(
        _keyInbox,
        data.map((n) => n.toJson()).toList(),
      );
    } catch (e) {
      debugPrint('Error menghapus notifikasi: $e');
    }
  }

  // Menghapus semua notifikasi dari inbox.
  Future<void> hapusSemuaInbox() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyInbox);
    } catch (e) {
      debugPrint('Error menghapus semua inbox: $e');
    }
  }

  // ==================================================
  // 4. NOTIFIKASI LANGSUNG
  // ==================================================
  Future<void> tampilkan({
    required int id,
    required String judul,
    required String isi,
  }) async {
    try {
      await init();

      if (!_initialized || !await izinAktif()) return;

      const details = NotificationDetails(android: _androidDetails);

      await _plugin.show(
        id: id,
        title: judul,
        body: isi,
        notificationDetails: details,
      );
    } catch (e) {
      debugPrint('Error menampilkan notifikasi: $e');
    }
  }

  // ==================================================
  // 5. NOTIFIKASI TERJADWAL
  // ==================================================
  Future<void> jadwalkan({
    required int id,
    required String judul,
    required String isi,
    required DateTime waktu,
  }) async {
    try {
      await init();

      if (!_initialized || !await izinAktif()) return;
      if (!waktu.isAfter(DateTime.now())) return;

      final waktuZona = tz.TZDateTime.from(waktu, tz.local);

      const details = NotificationDetails(android: _androidDetails);

      await _plugin.zonedSchedule(
        id: id,
        title: judul,
        body: isi,
        scheduledDate: waktuZona,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('Error menjadwalkan notifikasi: $e');
    }
  }

  // ==================================================
  // 6. MEMBATALKAN NOTIFIKASI ANDROID
  // ==================================================
  Future<void> batalkan(int id) async {
    try {
      await init();
      await _plugin.cancel(id: id);
    } catch (e) {
      debugPrint('Error membatalkan notifikasi ID $id: $e');
    }
  }

  Future<void> batalkanSemua() async {
    try {
      await init();
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('Error membatalkan semua notifikasi: $e');
    }
  }
}
