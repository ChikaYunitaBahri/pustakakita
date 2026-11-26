import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class DeviceService {
  Future<String> infoAndroid() async {
    if (kIsWeb) return 'Web browser';
    if (defaultTargetPlatform != TargetPlatform.android) {
      return 'Perangkat bukan Android';
    }

    final info = await DeviceInfoPlugin().androidInfo;
    final manufacturer = info.manufacturer.trim();
    final model = info.model.trim();
    final deviceName =
        [manufacturer, model].where((part) => part.isNotEmpty).join(' ');

    return '${deviceName.isEmpty ? 'Android' : deviceName} • Android ${info.version.release}';
  }

  Future<PermissionStatus> mintaIzinNotifikasi() =>
      Permission.notification.request();

  Future<PermissionStatus> statusIzinNotifikasi() =>
      Permission.notification.status;
}
