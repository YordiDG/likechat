import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ImageDatabaseHelper {
  // Singleton pattern
  static final ImageDatabaseHelper instance = ImageDatabaseHelper._internal();
  static Database? _database;

  // Constructor privado
  ImageDatabaseHelper._internal();

  // Método de fábrica para obtener la instancia singleton
  factory ImageDatabaseHelper() => instance;

  // Getter para la base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Método para inicializar la base de datos
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'images.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE images (
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            path TEXT UNIQUE
          )
        ''');
      },
    );
  }

  // Guardar una imagen
  Future<int> saveImage(String imagePath) async {
    final db = await database;
    return await db.insert(
      'images',
      {'path': imagePath},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Obtener la imagen guardada
  Future<String?> getProfileImage() async {
    final db = await database;
    final result = await db.query('images', limit: 1);
    if (result.isNotEmpty) {
      return result.first['path'] as String?;
    }
    return null; // Si no hay imagen guardada, retorna null
  }

  // Eliminar imagen por ruta
  Future<int> deleteImageByPath(String imagePath) async {
    final db = await database;
    return await db.delete(
        'images',
        where: 'path = ?',
        whereArgs: [imagePath]
    );
  }

  // Actualizar imagen
  Future<int> updateImage(String oldPath, String newPath) async {
    final db = await database;
    return await db.update(
        'images',
        {'path': newPath},
        where: 'path = ?',
        whereArgs: [oldPath]
    );
  }
}