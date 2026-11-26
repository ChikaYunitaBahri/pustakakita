import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/buku.dart';
import '../providers/peminjaman_provider.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final buku = ModalRoute.of(context)!.settings.arguments as Buku;
    final sudahDipinjam = context.watch<PeminjamanProvider>().sudahDipinjam(buku);

    return Scaffold(
      appBar: AppBar(title: Text(buku.judul)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              buku.judul,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('Penulis: ${buku.penulis}'),
            Text('Kategori: ${buku.kategori}'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: sudahDipinjam
                  ? null
                  : () => context.read<PeminjamanProvider>().pinjam(buku),
              icon: const Icon(Icons.bookmark_add),
              label: Text(sudahDipinjam ? 'Sudah dipinjam' : 'Pinjam buku ini'),
            ),
          ],
        ),
      ),
    );
  }
}