import 'package:flutter/material.dart';

import '../models/buku.dart';
import '../models/data_buku_contoh.dart';

/// Layar katalog dengan pencarian judul, filter kategori,
/// dan tampilan responsif (list di layar sempit, grid di layar lebar).
class KatalogCariScreen extends StatefulWidget {
  const KatalogCariScreen({super.key});

  @override
  State<KatalogCariScreen> createState() => _KatalogCariScreenState();
}

class _KatalogCariScreenState extends State<KatalogCariScreen> {
  final TextEditingController _cariCtrl = TextEditingController();
  String _kataKunci = '';
  String _kategori = 'Semua';

  List<String> get _daftarKategori =>
      ['Semua', ...daftarBukuContoh.map((b) => b.kategori).toSet()];

  List<Buku> get _hasil => daftarBukuContoh.where((b) {
        final cocokJudul =
            b.judul.toLowerCase().contains(_kataKunci.toLowerCase());
        final cocokKategori = _kategori == 'Semua' || b.kategori == _kategori;
        return cocokJudul && cocokKategori;
      }).toList();

  @override
  void dispose() {
    _cariCtrl.dispose();
    super.dispose();
  }

  void _buka(Buku b) => Navigator.pushNamed(context, '/detail', arguments: b);

  @override
  Widget build(BuildContext context) {
    final hasil = _hasil;

    return Scaffold(
      appBar: AppBar(title: const Text('Katalog')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _cariCtrl,
              onChanged: (v) => setState(() => _kataKunci = v),
              decoration: InputDecoration(
                hintText: 'Cari judul buku...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _kataKunci.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _cariCtrl.clear();
                          setState(() => _kataKunci = '');
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _daftarKategori.length,
              separatorBuilder: (context, i) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final k = _daftarKategori[i];
                return ChoiceChip(
                  label: Text(k),
                  selected: _kategori == k,
                  onSelected: (_) => setState(() => _kategori = k),
                );
              },
            ),
          ),
          Expanded(
            child: hasil.isEmpty
                ? const Center(child: Text('Buku tidak ditemukan'))
                : LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 600) {
                        return _buildList(hasil);
                      }
                      final kolom =
                          (constraints.maxWidth / 220).floor().clamp(2, 6);
                      return _buildGrid(hasil, kolom);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<Buku> data) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      itemCount: data.length,
      itemBuilder: (context, i) {
        final b = data[i];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _buka(b),
            child: SizedBox(
              height: 96,
              child: Row(
                children: [
                  AspectRatio(aspectRatio: 0.8, child: _Sampul(buku: b)),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            b.judul,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(b.penulis,
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(b.kategori,
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGrid(List<Buku> data, int kolom) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: kolom,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: data.length,
      itemBuilder: (context, i) {
        final b = data[i];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _buka(b),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _Sampul(buku: b)),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.judul,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        b.penulis,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Sampul buku: Image.network jika ada URL, kalau tidak placeholder ikon.
class _Sampul extends StatelessWidget {
  final Buku buku;
  const _Sampul({required this.buku});

  @override
  Widget build(BuildContext context) {
    final warna = Theme.of(context).colorScheme;
    final placeholder = Container(
      color: warna.primaryContainer,
      alignment: Alignment.center,
      child: Icon(Icons.menu_book, size: 36, color: warna.onPrimaryContainer),
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        if (buku.gambar != null)
          Image.network(
            buku.gambar!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) => placeholder,
          )
        else
          placeholder,
        Positioned(
          top: 6,
          left: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: warna.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              buku.kategori,
              style: TextStyle(color: warna.onPrimary, fontSize: 10),
            ),
          ),
        ),
      ],
    );
  }
}
