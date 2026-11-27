import 'package:flutter/material.dart';

import '../models/notifikasi.dart';
import '../services/notifikasi_service.dart';

class DaftarNotifikasiScreen extends StatefulWidget {
  const DaftarNotifikasiScreen({super.key});

  @override
  State<DaftarNotifikasiScreen> createState() => _DaftarNotifikasiScreenState();
}

class _DaftarNotifikasiScreenState extends State<DaftarNotifikasiScreen> {
  final NotifikasiService _service = NotifikasiService.instance;

  List<Notifikasi> _notifikasi = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _muatNotifikasi();
  }

  // Memuat data inbox.
  Future<void> _muatNotifikasi() async {
    final data = await _service.ambilInbox();

    if (!mounted) return;

    setState(() {
      _notifikasi = data;
      _loading = false;
    });
  }

  // Menandai satu notifikasi sudah dibaca.
  Future<void> _tandaiDibaca(Notifikasi n) async {
    if (n.dibaca) return;

    await _service.tandaiDibaca(n.id);
    await _muatNotifikasi();
  }

  // Menandai semua notifikasi sudah dibaca.
  Future<void> _tandaiSemua() async {
    await _service.tandaiSemuaDibaca();
    await _muatNotifikasi();
  }

  // Menghapus satu notifikasi.
  Future<void> _hapusNotifikasi(Notifikasi n) async {
    await _service.hapusInbox(n.id);
    await _muatNotifikasi();
  }

  // Menghapus semua notifikasi dengan konfirmasi.
  Future<void> _hapusSemua() async {
    final setuju = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Semua Notifikasi?'),
        content: const Text(
          'Semua notifikasi di inbox akan dihapus permanen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );

    if (setuju == true) {
      await _service.hapusSemuaInbox();
      await _muatNotifikasi();
    }
  }

  // Ikon berdasarkan tipe notifikasi.
  IconData _ikon(String tipe) {
    switch (tipe) {
      case 'peminjaman':
        return Icons.book_online_rounded;
      case 'pengingat':
        return Icons.access_time_rounded;
      case 'pengembalian':
        return Icons.assignment_turned_in_rounded;
      case 'perpanjangan':
        return Icons.event_repeat_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  // Warna berdasarkan tipe notifikasi.
  Color _warna(String tipe, BuildContext context) {
    switch (tipe) {
      case 'peminjaman':
        return Colors.green;
      case 'pengingat':
        return Colors.orange;
      case 'pengembalian':
        return Colors.blue;
      case 'perpanjangan':
        return Colors.purple;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  // Format tanggal dan waktu.
  String _formatWaktu(DateTime waktu) {
    final sekarang = DateTime.now();
    final selisih = sekarang.difference(waktu);

    if (selisih.inMinutes < 1 && !selisih.isNegative) {
      return 'Baru saja';
    }

    if (selisih.inMinutes < 60 && !selisih.isNegative) {
      return '${selisih.inMinutes} menit lalu';
    }

    if (selisih.inHours < 24 && !selisih.isNegative) {
      return '${selisih.inHours} jam lalu';
    }

    if (selisih.inDays == 1) {
      return 'Kemarin';
    }

    return '${waktu.day}/${waktu.month}/${waktu.year} '
        '${waktu.hour.toString().padLeft(2, '0')}:'
        '${waktu.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          if (_notifikasi.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'baca') {
                  _tandaiSemua();
                } else if (value == 'hapus') {
                  _hapusSemua();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'baca',
                  child: Text('Tandai semua dibaca'),
                ),
                const PopupMenuItem(
                  value: 'hapus',
                  child: Text('Hapus semua'),
                ),
              ],
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notifikasi.isEmpty
              ? _tampilanKosong(theme)
              : RefreshIndicator(
                  onRefresh: _muatNotifikasi,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    itemCount: _notifikasi.length,
                    itemBuilder: (context, index) {
                      final n = _notifikasi[index];
                      final warna = _warna(n.tipe, context);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        color: n.dibaca
                            ? theme.cardColor
                            : theme.colorScheme.primaryContainer
                                .withValues(alpha: 0.35),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: warna.withValues(alpha: 0.12),
                            child: Icon(
                              _ikon(n.tipe),
                              color: warna,
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  n.judul,
                                  style: TextStyle(
                                    fontWeight: n.dibaca
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (!n.dibaca)
                                Container(
                                  width: 9,
                                  height: 9,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(n.isi),
                                const SizedBox(height: 6),
                                Text(
                                  _formatWaktu(n.waktu),
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          onTap: () => _tandaiDibaca(n),
                          trailing: IconButton(
                            tooltip: 'Hapus notifikasi',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _hapusNotifikasi(n),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  // Tampilan ketika inbox masih kosong.
  Widget _tampilanKosong(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 72,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Notifikasi',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Notifikasi peminjaman dan pengingat buku '
              'akan muncul di sini.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
