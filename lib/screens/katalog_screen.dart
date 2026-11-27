import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/buku.dart';
import '../providers/buku_provider.dart';
import '../providers/favorit_provider.dart';
import '../services/notifikasi_service.dart';
import 'daftar_notifikasi_screen.dart';

class KatalogScreen extends StatefulWidget {
  const KatalogScreen({super.key});

  @override
  State<KatalogScreen> createState() => _KatalogScreenState();
}

class _KatalogScreenState extends State<KatalogScreen> {
  static const String _semua = 'Semua';

  final _pencarian = TextEditingController();

  String _kata = '';
  String _kategori = _semua;

  int _jumlahBelumDibaca = 0;

  @override
  void initState() {
    super.initState();
    _muatBadgeNotifikasi();
  }

  @override
  void dispose() {
    _pencarian.dispose();
    super.dispose();
  }

  // Memuat jumlah notifikasi yang belum dibaca.
  Future<void> _muatBadgeNotifikasi() async {
    final jumlah = await NotifikasiService.instance.jumlahBelumDibaca();

    if (!mounted) return;

    setState(() {
      _jumlahBelumDibaca = jumlah;
    });
  }

  // Membuka halaman daftar notifikasi.
  // Badge diperbarui setelah pengguna kembali ke katalog.
  Future<void> _bukaNotifikasi() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DaftarNotifikasiScreen(),
      ),
    );

    await _muatBadgeNotifikasi();
  }

  // Widget ikon lonceng beserta badge.
  Widget _ikonNotifikasi() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.notifications_outlined),
        if (_jumlahBelumDibaca > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(3),
              constraints: const BoxConstraints(
                minWidth: 17,
                minHeight: 17,
              ),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _jumlahBelumDibaca > 99 ? '99+' : '$_jumlahBelumDibaca',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BukuProvider>();

    final kata = _kata.trim().toLowerCase();

    final hasil = provider.data.where((b) {
      final cocokJudul = b.judul.toLowerCase().contains(kata);

      final cocokKategori = _kategori == _semua || b.kategori == _kategori;

      return cocokJudul && cocokKategori;
    }).toList();

    final daftarChip = <String>{_semua, ...provider.daftarKategori}.toList();

    Widget isi;

    if (provider.loading) {
      isi = const Center(
        child: CircularProgressIndicator(),
      );
    } else if (provider.error != null) {
      isi = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                provider.error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => context.read<BukuProvider>().muat(),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    } else if (hasil.isEmpty) {
      isi = const Center(
        child: Text('Buku tidak ditemukan'),
      );
    } else {
      isi = _GridBuku(daftar: hasil);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog PustakaKita'),
        actions: [
          IconButton(
            tooltip: 'Notifikasi',
            icon: _ikonNotifikasi(),
            onPressed: _bukaNotifikasi,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Pencarian buku.
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: TextField(
                controller: _pencarian,
                onChanged: (nilai) {
                  setState(() => _kata = nilai);
                },
                decoration: InputDecoration(
                  hintText: 'Cari judul buku',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _kata.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Hapus pencarian',
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _pencarian.clear();
                            setState(() => _kata = '');
                          },
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // Filter kategori.
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  for (final k in daftarChip)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(k),
                        selected: _kategori == k,
                        onSelected: (_) {
                          setState(() => _kategori = k);
                        },
                      ),
                    ),
                ],
              ),
            ),

            // Daftar buku.
            Expanded(child: isi),
          ],
        ),
      ),
    );
  }
}

// ==================================================
// GRID BUKU
// ==================================================

class _GridBuku extends StatelessWidget {
  const _GridBuku({required this.daftar});

  final List<Buku> daftar;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, batas) {
        // Jumlah kolom mengikuti lebar layar.
        final kolom = batas.maxWidth < 600
            ? 2
            : batas.maxWidth < 900
                ? 3
                : 5;

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: kolom,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.62,
          ),
          itemCount: daftar.length,
          itemBuilder: (context, i) {
            return _KartuBuku(buku: daftar[i]);
          },
        );
      },
    );
  }
}

// ==================================================
// KARTU BUKU
// ==================================================

class _KartuBuku extends StatelessWidget {
  const _KartuBuku({required this.buku});

  final Buku buku;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    final favoritProvider = context.watch<FavoritProvider>();
    final sudahFavorit = favoritProvider.isFavorit(buku);

    // Android memblokir gambar HTTP, jadi diubah ke HTTPS.
    final url = buku.gambar?.replaceFirst('http://', 'https://');

    final pengganti = Container(
      color: tema.colorScheme.surfaceContainerHighest,
      child: const Icon(Icons.menu_book, size: 48),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          '/detail',
          arguments: buku,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Gambar sampul buku.
                  url == null
                      ? pengganti
                      : Image.network(
                          url,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return pengganti;
                          },
                        ),

                  // Label kategori.
                  Positioned(
                    left: 6,
                    right: 6,
                    bottom: 6,
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: tema.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          buku.kategori,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tema.textTheme.labelSmall?.copyWith(
                            color: tema.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Tombol favorit.
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Material(
                      color: tema.colorScheme.surface.withAlpha(230),
                      shape: const CircleBorder(),
                      child: IconButton(
                        tooltip: sudahFavorit
                            ? 'Hapus dari favorit'
                            : 'Tambah ke favorit',
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          sudahFavorit ? Icons.favorite : Icons.favorite_border,
                          color: sudahFavorit ? Colors.red : null,
                        ),
                        onPressed: () {
                          context.read<FavoritProvider>().toggle(buku);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Informasi buku.
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    buku.judul,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: tema.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          buku.penulis,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tema.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
