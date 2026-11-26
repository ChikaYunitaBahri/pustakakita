import 'package:flutter/material.dart';

class DemoSetStateScreen extends StatefulWidget {
  const DemoSetStateScreen({super.key});

  @override
  State<DemoSetStateScreen> createState() => _DemoSetStateScreenState();
}

class _DemoSetStateScreenState extends State<DemoSetStateScreen> {
  int jumlahDipinjam = 0; // badge (butir 24)
  bool favorit = false; // like (butir 25)
  bool hanyaTersedia = false; // switch (butir 26)
  final _formKey = GlobalKey<FormState>(); // form (butir 27)
  final _namaCtrl = TextEditingController();

  @override
  void dispose() {
    _namaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo setState'),
        actions: [
          Badge(
            label: Text('$jumlahDipinjam'),
            child: const Icon(Icons.bookmark),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => setState(() => jumlahDipinjam++),
              child: const Text('Tambah jumlah dipinjam'),
            ),
            IconButton(
              icon: Icon(favorit ? Icons.favorite : Icons.favorite_border),
              onPressed: () => setState(() => favorit = !favorit),
            ),
            SwitchListTile(
              title: const Text('Hanya yang tersedia'),
              subtitle: Text(hanyaTersedia ? 'Aktif' : 'Nonaktif'),
              value: hanyaTersedia,
              onChanged: (v) => setState(() => hanyaTersedia = v),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _namaCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Nama peminjam'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Nama wajib diisi'
                            : null,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Form valid')),
                        );
                      }
                    },
                    child: const Text('Kirim'),
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