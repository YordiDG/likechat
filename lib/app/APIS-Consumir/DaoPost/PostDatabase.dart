import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../home/shortVideos/Posts/PostClass.dart';

class PostDatabase {
  static final PostDatabase instance = PostDatabase._init();
  static Database? _database;

  PostDatabase._init();

  // Método para codificar las rutas de imágenes a JSON
  String _encodeImagePaths(List<String> paths) {
    return json.encode(paths);
  }

  // Método para decodificar el JSON almacenado a una lista de rutas
  List<String> _decodeImagePaths(String encodedPaths) {
    return List<String>.from(json.decode(encodedPaths));
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('like.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE posts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT,
        image_paths TEXT, -- Cambiado para almacenar rutas múltiples en formato JSON
        createdAt TEXT,
        userName TEXT,
        userAvatar TEXT,
        isLiked INTEGER,
        likeCount INTEGER
      )
    ''');
  }

  Future<int> createPost(Post post) async {
    final db = await database;
    final id = await db.insert('posts', {
      'description': post.description,
      'image_paths': _encodeImagePaths(post.imagePaths), // Se codifica la lista
      'createdAt': post.createdAt.toIso8601String(),
      'userName': post.userName,
      'userAvatar': post.userAvatar,
      'isLiked': post.isLiked ? 1 : 0,
      'likeCount': post.likeCount,
    });
    return id;
  }

  Future<List<Post>> getAllPosts() async {
    final db = await database;
    final result = await db.query('posts', orderBy: 'createdAt DESC');

    return result.map((map) => Post(
      id: map['id'] as int,
      description: map['description'] as String,
      imagePaths: _decodeImagePaths(map['image_paths'] as String), // Decodifica las rutas
      createdAt: DateTime.parse(map['createdAt'] as String),
      userName: map['userName'] as String,
      userAvatar: map['userAvatar'] as String,
      isLiked: map['isLiked'] == 1,
      likeCount: map['likeCount'] as int,
    )).toList();
  }

  Future<int> updatePost(Post post) async {
    final db = await database;
    return await db.update(
      'posts',
      {
        'description': post.description,
        'image_paths': _encodeImagePaths(post.imagePaths), // Actualiza las rutas
        'createdAt': post.createdAt.toIso8601String(),
        'userName': post.userName,
        'userAvatar': post.userAvatar,
        'isLiked': post.isLiked ? 1 : 0,
        'likeCount': post.likeCount,
      },
      where: 'id = ?',
      whereArgs: [post.id],
    );
  }

  Future<int> deletePost(int id) async {
    final db = await database;
    return await db.delete(
      'posts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
