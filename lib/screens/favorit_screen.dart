
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/buku.dart';
import '../providers/favorit_provider.dart';

class FavoritScreen extends StatelessWidget {
  const FavoritScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FavoritProvider>();
    final daftar = provider.semua;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buku Favorit'),
      ),
      body: daftar.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 72,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Belum ada buku favorit',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tambahkan buku ke favoritmu dari halaman Katalog.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: daftar.length,
              itemBuilder: (context, index) {
                final buku = daftar[index];

                return _ItemFavorit(buku: buku);
              },
            ),
    );
  }
}

class _ItemFavorit extends StatelessWidget {
  const _ItemFavorit({required this.buku});

  final Buku buku;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    final url = buku.gambar?.replaceFirst('http://', 'https://');

    final gambarPengganti = Container(
      width: 90,
      color: tema.colorScheme.surfaceContainerHighest,
      child: const Icon(Icons.menu_book, size: 36),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: SizedBox(
          width: 70,
          height: 100,
          child: url == null
              ? gambarPengganti
              : Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      gambarPengganti,
                ),
        ),
        title: Text(
          buku.judul,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${buku.penulis}\n${buku.kategori}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: IconButton(
          tooltip: 'Hapus dari favorit',
          icon: const Icon(
            Icons.favorite,
            color: Colors.red,
          ),
          onPressed: () {
            context.read<FavoritProvider>().toggle(buku);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${buku.judul} dihapus dari favorit'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/detail',
            arguments: buku,
          );
        },
      ),
    );
  }
}
