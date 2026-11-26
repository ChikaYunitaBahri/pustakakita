import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:pustakakita/providers/favorit_provider.dart';
import 'package:pustakakita/services/device_service.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});
  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final _device = DeviceService();
  String _deviceText = 'Informasi perangkat belum dimuat';
  String _permissionText = 'Status izin notifikasi belum diperiksa';
  bool _loadingPermission = false;

  @override
  void initState() {
    super.initState();
    _loadDevice();
    _loadPermissionStatus();
  }

  Future<void> _loadPermissionStatus() async {
    final status = await _device.statusIzinNotifikasi();
    if (!mounted) return;
    setState(() => _permissionText = _permissionLabel(status));
  }

  String _permissionLabel(PermissionStatus status) => switch (status) {
        PermissionStatus.granted => 'Izin diizinkan',
        PermissionStatus.denied => 'Izin ditolak',
        PermissionStatus.permanentlyDenied =>
          'Izin ditolak permanen. Aktifkan melalui Pengaturan.',
        PermissionStatus.restricted => 'Izin dibatasi oleh sistem',
        _ => 'Status izin: $status',
      };

  Future<void> _loadDevice() async {
    try {
      final value = await _device.infoAndroid();
      if (mounted) setState(() => _deviceText = value);
    } catch (_) {
      if (mounted) {
        setState(() => _deviceText =
            'Informasi perangkat tidak tersedia pada platform ini');
      }
    }
  }

  Future<void> _requestPermission() async {
    setState(() => _loadingPermission = true);
    final status = await _device.mintaIzinNotifikasi();
    if (!mounted) return;
    setState(() {
      _loadingPermission = false;
      _permissionText = _permissionLabel(status);
    });

    if (status == PermissionStatus.permanentlyDenied) {
      await openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final favorit = context.watch<FavoritProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Profil & Pengaturan')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text('Buku favorit tersimpan: ${favorit.semua.length}'),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.phone_android),
          title: const Text('Informasi perangkat'),
          subtitle: Text(_deviceText),
          trailing: IconButton(
              icon: const Icon(Icons.refresh), onPressed: _loadDevice),
        ),
        ListTile(
          leading: const Icon(Icons.notifications_active),
          title: const Text('Izin notifikasi'),
          subtitle: Text(_permissionText),
          trailing: FilledButton(
            onPressed: _loadingPermission ? null : _requestPermission,
            child: Text(_loadingPermission ? 'Memproses...' : 'Minta izin'),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/login'),
          child: const Text('Ke halaman login'),
        ),
      ]),
    );
  }
}
