import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/peminjaman_provider.dart';

class PeminjamanScreen extends StatelessWidget {
  const PeminjamanScreen({super.key});

  String _formatTanggal(DateTime tanggal) {
    const namaBulan = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return '${tanggal.day} ${namaBulan[tanggal.month - 1]} ${tanggal.year}';
  }

  Future<void> _konfirmasiKembalikan(
    BuildContext context,
    dynamic buku,
  ) async {
    final hasil = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Kembalikan Buku'),
        content: Text(
          'Apakah kamu yakin ingin mengembalikan '
          '"${buku.judul}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Ya, Kembalikan'),
          ),
        ],
      ),
    );

    if (hasil != true || !context.mounted) return;

    await context.read<PeminjamanProvider>().kembalikan(buku);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Buku berhasil dikembalikan.'),
      ),
    );
  }

  Future<void> _konfirmasiPerpanjang(
    BuildContext context,
    dynamic buku,
  ) async {
    final hasil = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Perpanjang Peminjaman'),
        content: Text(
          'Perpanjang masa peminjaman buku '
          '"${buku.judul}" selama 7 hari?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Perpanjang'),
          ),
        ],
      ),
    );

    if (hasil != true || !context.mounted) return;

    await context.read<PeminjamanProvider>().perpanjang(buku);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Masa peminjaman berhasil diperpanjang 7 hari.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final warna = tema.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Peminjaman'),
      ),
      body: Consumer<PeminjamanProvider>(
        builder: (context, p, _) {
          if (p.dipinjam.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.menu_book_outlined,
                      size: 72,
                      color: warna.primary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum Ada Buku Dipinjam',
                      style: tema.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Buku yang kamu pinjam akan muncul di sini.',
                      textAlign: TextAlign.center,
                      style: tema.textTheme.bodyMedium?.copyWith(
                        color: warna.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: p.dipinjam.length,
            itemBuilder: (context, i) {
              final b = p.dipinjam[i];
              final terlambat = b.tglJatuhTempo.isBefore(DateTime.now());

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 90,
                              height: 125,
                              child: b.gambar != null && b.gambar!.isNotEmpty
                                  ? Image.network(
                                      b.gambar!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              _placeholder(tema),
                                    )
                                  : _placeholder(tema),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  b.judul,
                                  style: tema.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  b.penulis,
                                  style: tema.textTheme.bodyMedium?.copyWith(
                                    color: warna.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: terlambat
                                        ? warna.errorContainer
                                        : warna.primaryContainer,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    terlambat
                                        ? 'Melewati jatuh tempo'
                                        : 'Sedang dipinjam',
                                    style: tema.textTheme.labelSmall?.copyWith(
                                      color: terlambat
                                          ? warna.onErrorContainer
                                          : warna.onPrimaryContainer,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Divider(color: warna.outlineVariant),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 18,
                            color: warna.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tanggal pinjam',
                            style: tema.textTheme.bodySmall,
                          ),
                          const Spacer(),
                          Text(
                            _formatTanggal(b.tglPinjam),
                            style: tema.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.event_outlined,
                            size: 18,
                            color: terlambat ? warna.error : warna.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Jatuh tempo',
                            style: tema.textTheme.bodySmall,
                          ),
                          const Spacer(),
                          Text(
                            _formatTanggal(b.tglJatuhTempo),
                            style: tema.textTheme.bodySmall?.copyWith(
                              color: terlambat ? warna.error : null,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _konfirmasiKembalikan(context, b),
                              icon: const Icon(Icons.assignment_return),
                              label: const Text('Kembalikan'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () =>
                                  _konfirmasiPerpanjang(context, b),
                              icon: const Icon(Icons.update),
                              label: const Text('Perpanjang 7 Hari'),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _placeholder(ThemeData tema) {
    return Container(
      color: tema.colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.book_outlined,
        size: 40,
        color: tema.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
