import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/peminjaman_provider.dart';

class PeminjamanScreen extends StatelessWidget {
  const PeminjamanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Peminjaman')),
      body: Consumer<PeminjamanProvider>(
        builder: (context, p, _) {
          if (p.dipinjam.isEmpty) {
            return const Center(child: Text('Belum ada buku dipinjam'));
          }
          return ListView.builder(
            itemCount: p.dipinjam.length,
            itemBuilder: (context, i) {
              final b = p.dipinjam[i];
              return ListTile(
                title: Text(b.judul),
                subtitle: Text(b.penulis),
                trailing: IconButton(
                  icon: const Icon(Icons.undo),
                  tooltip: 'Kembalikan',
                  onPressed: () =>
                      context.read<PeminjamanProvider>().kembalikan(b),
                ),
              );
            },
          );
        },
      ),
    );
  }
}