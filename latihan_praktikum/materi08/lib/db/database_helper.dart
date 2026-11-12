import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import '../models/kontak.dart';

class DatabaseHelper {
  DatabaseHelper._init();

  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    // sqflite native tidak berjalan langsung di Chrome.
    // Untuk Flutter Web, gunakan implementasi SQLite berbasis WASM.
    late final String path;
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      path = 'kontak_web.db';
    } else {
      path = join(await getDatabasesPath(), 'kontak.db');
    }

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE kontak (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama TEXT NOT NULL,
            telepon TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<List<Kontak>> getKontak() async {
    final db = await database;
    final data = await db.query('kontak', orderBy: 'id DESC');
    return data.map((row) => Kontak.fromMap(row)).toList();
  }

  Future<int> tambahKontak(Kontak kontak) async {
    final db = await database;
    return db.insert('kontak', {
      'nama': kontak.nama,
      'telepon': kontak.telepon,
    });
  }

  Future<int> editKontak(Kontak kontak) async {
    final db = await database;
    return db.update(
      'kontak',
      {
        'nama': kontak.nama,
        'telepon': kontak.telepon,
      },
      where: 'id = ?',
      whereArgs: [kontak.id],
    );
  }

  Future<int> hapusKontak(int id) async {
    final db = await database;
    return db.delete(
      'kontak',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
