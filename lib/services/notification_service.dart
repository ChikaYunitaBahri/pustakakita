import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Pontianak'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: android,
      ),
    );

    const channel = AndroidNotificationChannel(
      'pustakakita_due',
      'Pengingat Peminjaman',
      description: 'Pengingat tanggal jatuh tempo buku',
      importance: Importance.high,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _initialized = true;
  }

  Future<bool> mintaIzin() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    return await android?.requestNotificationsPermission() ?? false;
  }

  Future<void> jadwalkanJatuhTempo(
    int id,
    String judul,
    DateTime jatuhTempo,
  ) async {
    await init();

    final reminder = jatuhTempo.subtract(const Duration(days: 1));
    final now = DateTime.now();

    if (!reminder.isAfter(now) && !jatuhTempo.isAfter(now)) {
      return;
    }

    final scheduleAt = reminder.isAfter(now) ? reminder : jatuhTempo;

    await _plugin.zonedSchedule(
      id: id,
      title: 'Pengingat pengembalian buku',
      body:
          'Buku "$judul" jatuh tempo pada ${jatuhTempo.day}/${jatuhTempo.month}/${jatuhTempo.year}.',
      scheduledDate: tz.TZDateTime.from(scheduleAt, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'pustakakita_due',
          'Pengingat Peminjaman',
          channelDescription: 'Pengingat tanggal jatuh tempo buku',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> batalkan(int id) => _plugin.cancel(id: id);
}