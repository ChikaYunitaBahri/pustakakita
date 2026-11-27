
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/peminjaman_provider.dart';
import '../providers/favorit_provider.dart';
import 'katalog_screen.dart';
import 'favorit_screen.dart';
import 'peminjaman_screen.dart';
import 'profil_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final List<Widget> _pages = const [
    KatalogScreen(),
    FavoritScreen(),
    PeminjamanScreen(),
    ProfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Katalog',
          ),

          // Tab Favorit dengan badge jumlah buku
          BottomNavigationBarItem(
            icon: Selector<FavoritProvider, int>(
              selector: (_, p) => p.semua.length,
              builder: (context, jumlah, child) => Badge(
                isLabelVisible: jumlah > 0,
                label: Text('$jumlah'),
                child: const Icon(Icons.favorite),
              ),
            ),
            label: 'Favorit',
          ),

          // Tab Peminjaman dengan badge jumlah pinjaman
          BottomNavigationBarItem(
            icon: Selector<PeminjamanProvider, int>(
              selector: (_, p) => p.jumlah,
              builder: (context, jumlah, child) => Badge(
                isLabelVisible: jumlah > 0,
                label: Text('$jumlah'),
                child: const Icon(Icons.bookmark),
              ),
            ),
            label: 'Peminjaman',
          ),

          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
