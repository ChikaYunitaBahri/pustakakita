import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/buku_provider.dart';

class KatalogScreen extends StatelessWidget {
  const KatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Katalog')),
      body: Consumer<BukuProvider>(
        builder: (context, p, _) {
          if (p.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (p.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(p.error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => p.muat(),
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: p.data.length,
            itemBuilder: (context, i) {
              final b = p.data[i];
              return ListTile(
                title: Text(b.judul),
                subtitle: Text('${b.penulis} • ${b.kategori}'),
                onTap: () =>
                    Navigator.pushNamed(context, '/detail', arguments: b),
              );
            },
          );
        },
      ),
    );
  }
}