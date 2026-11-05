import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import '../models/pembacaan_sensor.dart';

class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      _database = await openDatabase(
        'ruangpantau_sensor.db',
        version: 1,
        onCreate: _createTables,
      );
    } else {
      final databasesPath = await getDatabasesPath();
      final databasePath = path.join(databasesPath, 'ruangpantau_sensor.db');
      _database = await openDatabase(
        databasePath,
        version: 1,
        onCreate: _createTables,
      );
    }

    return _database!;
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE pembacaan_sensor (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        jenis_sensor TEXT NOT NULL,
        nilai REAL NOT NULL,
        lokasi_pos TEXT NOT NULL,
        waktu TEXT NOT NULL
      )
    ''');
  }

  Future<int> tambahPembacaan(PembacaanSensor sensor) async {
    final db = await database;
    final data = sensor.toMap()..remove('id');

    return db.insert('pembacaan_sensor', data);
  }

  Future<List<PembacaanSensor>> ambilSemuaPembacaan({
    String? jenisSensor,
  }) async {
    final db = await database;
    final List<Map<String, dynamic>> rows;

    if (jenisSensor == null || jenisSensor == 'semua') {
      rows = await db.query(
        'pembacaan_sensor',
        orderBy: 'waktu DESC, id DESC',
      );
    } else {
      rows = await db.query(
        'pembacaan_sensor',
        where: 'jenis_sensor = ?',
        whereArgs: [jenisSensor],
        orderBy: 'waktu DESC, id DESC',
      );
    }

    return rows.map(PembacaanSensor.fromMap).toList();
  }

  Future<List<PembacaanSensor>> ambilPembacaanTerbaru() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT p.*
      FROM pembacaan_sensor AS p
      INNER JOIN (
        SELECT jenis_sensor, MAX(id) AS id_terbaru
        FROM pembacaan_sensor
        GROUP BY jenis_sensor
      ) AS terbaru ON p.id = terbaru.id_terbaru
      ORDER BY p.jenis_sensor ASC
    ''');

    return rows.map(PembacaanSensor.fromMap).toList();
  }

  Future<int> ubahPembacaan(int id, double nilaiBaru) async {
    final db = await database;

    return db.update(
      'pembacaan_sensor',
      {'nilai': nilaiBaru},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> hapusPembacaan(int id) async {
    final db = await database;

    return db.delete(
      'pembacaan_sensor',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
