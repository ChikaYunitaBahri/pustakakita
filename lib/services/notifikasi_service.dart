import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotifikasiService {
  // Singleton: hanya satu instance service untuk seluruh aplikasi.
  NotifikasiService._();

  static final NotifikasiService instance = NotifikasiService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ID channel notifikasi.
  static const String _channelId = 'pustakakita_notifikasi';
  static const String _channelName = 'Notifikasi PustakaKita';
  static const String _channelDescription =
      'Notifikasi konfirmasi dan pengingat peminjaman buku';

  // Detail tampilan notifikasi Android.
  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
    _channelId,
    _channelName,
    channelDescription: _channelDescription,
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
  );

  // --------------------------------------------------
  // 1. INISIALISASI SERVICE
  // --------------------------------------------------
  Future<void> init() async {
    if (_initialized) return;

    try {
      // Inisialisasi database timezone.
      tzdata.initializeTimeZones();

      // Menggunakan zona waktu Pontianak.
      tz.setLocalLocation(
        tz.getLocation('Asia/Pontianak'),
      );

      // Pengaturan inisialisasi Android.
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      );

      // Inisialisasi plugin notifikasi.
      await _plugin.initialize(settings: settings);

      _initialized = true;

      debugPrint('NotifikasiService berhasil diinisialisasi.');
    } catch (e) {
      debugPrint('Error init NotifikasiService: $e');
    }
  }

  // --------------------------------------------------
  // 2. MEMERIKSA IZIN NOTIFIKASI
  // --------------------------------------------------
  Future<bool> izinAktif() async {
    try {
      final status = await Permission.notification.status;

      debugPrint('Status izin notifikasi: $status');

      return status.isGranted;
    } catch (e) {
      debugPrint('Error memeriksa izin notifikasi: $e');
      return false;
    }
  }

  // --------------------------------------------------
  // 3. MEMINTA IZIN NOTIFIKASI
  // --------------------------------------------------
  Future<bool> mintaIzin() async {
    try {
      final status = await Permission.notification.request();

      debugPrint('Hasil permintaan izin: $status');

      return status.isGranted;
    } catch (e) {
      debugPrint('Error meminta izin notifikasi: $e');
      return false;
    }
  }

  // --------------------------------------------------
  // 4. MENAMPILKAN NOTIFIKASI LANGSUNG
  // --------------------------------------------------
  Future<void> tampilkan({
    required int id,
    required String judul,
    required String isi,
  }) async {
    try {
      await init();

      if (!_initialized) {
        debugPrint('Notifikasi gagal: service belum terinisialisasi.');
        return;
      }

      if (!await izinAktif()) {
        debugPrint('Notifikasi tidak ditampilkan: izin belum diberikan.');
        return;
      }

      const details = NotificationDetails(
        android: _androidDetails,
      );

      await _plugin.show(
        id: id,
        title: judul,
        body: isi,
        notificationDetails: details,
      );

      debugPrint('Notifikasi langsung berhasil ditampilkan: $judul');
    } catch (e) {
      debugPrint('Error menampilkan notifikasi: $e');
    }
  }

  // --------------------------------------------------
  // 5. MENJADWALKAN NOTIFIKASI
  // --------------------------------------------------
  Future<void> jadwalkan({
    required int id,
    required String judul,
    required String isi,
    required DateTime waktu,
  }) async {
    try {
      await init();

      if (!_initialized) {
        debugPrint('Jadwal gagal: service belum terinisialisasi.');
        return;
      }

      if (!await izinAktif()) {
        debugPrint('Jadwal gagal: izin notifikasi belum diberikan.');
        return;
      }

      // Pastikan waktu jadwal belum lewat.
      if (!waktu.isAfter(DateTime.now())) {
        debugPrint('Jadwal gagal: waktu yang ditentukan sudah lewat.');
        return;
      }

      // Konversi waktu ke timezone lokal aplikasi.
      final waktuZona = tz.TZDateTime.from(
        waktu,
        tz.local,
      );

      const details = NotificationDetails(
        android: _androidDetails,
      );

      await _plugin.zonedSchedule(
        id: id,
        title: judul,
        body: isi,
        scheduledDate: waktuZona,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      debugPrint(
        'Notifikasi berhasil dijadwalkan pada $waktuZona',
      );
    } catch (e) {
      debugPrint('Error menjadwalkan notifikasi: $e');
    }
  }

  // --------------------------------------------------
  // 6. MEMBATALKAN NOTIFIKASI BERDASARKAN ID
  // --------------------------------------------------
  Future<void> batalkan(int id) async {
    try {
      await init();

      await _plugin.cancel(id: id);

      debugPrint('Notifikasi dengan ID $id berhasil dibatalkan.');
    } catch (e) {
      debugPrint('Error membatalkan notifikasi ID $id: $e');
    }
  }

  // --------------------------------------------------
  // 7. MEMBATALKAN SEMUA NOTIFIKASI
  // --------------------------------------------------
  Future<void> batalkanSemua() async {
    try {
      await init();

      await _plugin.cancelAll();

      debugPrint('Semua notifikasi berhasil dibatalkan.');
    } catch (e) {
      debugPrint('Error membatalkan semua notifikasi: $e');
    }
  }
}