import 'package:flutter/material.dart';

import '../models/buku.dart';

class KatalogScreen extends StatelessWidget {
  const KatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final contoh = [
      Buku(
        id: '1',
        judul: 'Flutter Dasar',
        penulis: 'Tim A',
        kategori: 'Teknologi',
      ),
      Buku(
        id: '2',
        judul: 'Laskar Pelangi',
        penulis: 'Andrea Hirata',
        kategori: 'Novel',
      ),
      Buku(
        id: '3',
        judul: 'Basis Data',
        penulis: 'Tim B',
        kategori: 'Teknologi',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Katalog')),
      body: ListView.builder(
        itemCount: contoh.length,
        itemBuilder: (context, i) {
          final b = contoh[i];
          return ListTile(
            title: Text(b.judul),
            subtitle: Text(b.penulis),
            onTap: () => Navigator.pushNamed(context, '/detail', arguments: b),
          );
        },
      ),
    );
  }
}