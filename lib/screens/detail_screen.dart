import 'package:flutter/material.dart';

import '../models/buku.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final buku = ModalRoute.of(context)!.settings.arguments as Buku;

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
          ],
        ),
      ),
    );
  }
}