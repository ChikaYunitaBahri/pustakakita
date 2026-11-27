import 'package:path/path.dart';

import 'package:sqflite/sqflite.dart';

import '../models/peminjaman.dart';

 

class DbHelper {

  DbHelper._();

  static final DbHelper instance = DbHelper._();

  static const _namaDb = 'pustakakita.db';

  static const tabel = 'loans';

  Database? _db;

 

  Future<Database> get database async {

    _db ??= await _buka();

    return _db!;

  }

 

  Future<Database> _buka() async {

    final path = join(await getDatabasesPath(), _namaDb);

    return openDatabase(path, version: 1, onCreate: (db, version) async {

      await db.execute('''

        CREATE TABLE $tabel (

          id INTEGER PRIMARY KEY AUTOINCREMENT,

          user_id INTEGER NOT NULL DEFAULT 0,

          book_id TEXT NOT NULL,

          judul TEXT NOT NULL,

          penulis TEXT NOT NULL,

          kategori TEXT NOT NULL,

          gambar TEXT,

          tgl_pinjam TEXT NOT NULL,

          tgl_jatuh_tempo TEXT NOT NULL,

          tgl_kembali TEXT,

          status TEXT NOT NULL

        )

      ''');

    });

  }

 

  Future<int> tambah(Peminjaman p) async {

    final map = p.toMap()..remove('id');

    return (await database).insert(tabel, map);

  }

 

  Future<List<Peminjaman>> semua() async {

    final rows = await (await database).query(tabel,

        orderBy: 'tgl_pinjam DESC');

    return rows.map(Peminjaman.fromMap).toList();

  }

 

  Future<int> ubah(int id, Map<String, Object?> nilai) async =>

      (await database).update(tabel, nilai,

          where: 'id = ?', whereArgs: [id]);

 

  Future<int> hapus(int id) async =>

      (await database).delete(tabel, where: 'id = ?', whereArgs: [id]);

}