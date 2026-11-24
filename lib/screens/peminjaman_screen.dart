import 'package:flutter/material.dart';

class PeminjamanScreen extends StatelessWidget {
  const PeminjamanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Peminjaman')),
      body: const Center(child: Text('Halaman peminjaman')),
    );
  }
}