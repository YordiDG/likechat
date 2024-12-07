import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../dao/Sticker.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'stickers.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE favorites(id TEXT PRIMARY KEY, url TEXT)',
        );
      },
    );
  }

  Future<void> insertFavorite(Sticker sticker) async {
    final db = await database;
    await db.insert(
      'favorites',
      sticker.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Sticker>> getFavorites() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('favorites');
    return List.generate(maps.length, (i) {
      return Sticker.fromMap(maps[i]);
    });
  }

  Future<void> deleteFavorite(Sticker sticker) async {
    final db = await database;
    await db.delete(
      'favorites',
      where: 'id = ?',
      whereArgs: [sticker.id],
    );
  }

}
