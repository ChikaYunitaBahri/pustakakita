
import 'package:flutter/material.dart';
import '../services/notifikasi_service.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  final NotifikasiService _notifikasi = NotifikasiService.instance;

  bool _loading = false;

  Future<void> _mintaIzin() async {
    setState(() => _loading = true);

    final hasil = await _notifikasi.mintaIzin();

    if (!mounted) return;
    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          hasil
              ? 'Izin notifikasi berhasil diberikan.'
              : 'Izin notifikasi belum diberikan.',
        ),
      ),
    );
  }

  Future<void> _tesNotifikasiLangsung() async {
    setState(() => _loading = true);

    await _notifikasi.tampilkan(
      id: 999991,
      judul: 'Tes Notifikasi PustakaKita',
      isi: 'Notifikasi langsung berhasil ditampilkan!',
    );

    if (!mounted) return;
    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perintah notifikasi langsung selesai.')),
    );
  }

  Future<void> _tesNotifikasiTerjadwal() async {
    setState(() => _loading = true);

    await _notifikasi.jadwalkan(
      id: 999992,
      judul: 'Tes Pengingat PustakaKita',
      isi: 'Ini adalah notifikasi terjadwal 10 detik.',
      waktu: DateTime.now().add(const Duration(seconds: 10)),
    );

    if (!mounted) return;
    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notifikasi dijadwalkan 10 detik dari sekarang.'),
      ),
    );
  }

  Future<void> _batalkanTes() async {
    await _notifikasi.batalkan(999991);
    await _notifikasi.batalkan(999992);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifikasi tes dibatalkan.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Notifikasi'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(
            Icons.notifications_active_outlined,
            size: 72,
          ),
          const SizedBox(height: 16),
          Text(
            'Pengujian Notifikasi',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Gunakan menu ini untuk memastikan izin dan fitur '
            'notifikasi PustakaKita berjalan dengan baik.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: _loading ? null : _mintaIzin,
            icon: const Icon(Icons.security),
            label: const Text('Minta Izin Notifikasi'),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _loading ? null : _tesNotifikasiLangsung,
            icon: const Icon(Icons.notifications),
            label: const Text('Tes Notifikasi Langsung'),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _loading ? null : _tesNotifikasiTerjadwal,
            icon: const Icon(Icons.schedule),
            label: const Text('Tes Notifikasi 10 Detik'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _loading ? null : _batalkanTes,
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Batalkan Notifikasi Tes'),
          ),
          if (_loading) ...[
            const SizedBox(height: 24),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }
}
