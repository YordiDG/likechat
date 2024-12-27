import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../home/shortVideos/Posts/PostClass.dart';

class PostDatabase {
  static final PostDatabase instance = PostDatabase._init();
  static Database? _database;

  PostDatabase._init();

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
        imagePath TEXT,
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
      'imagePath': post.imagePaths.isNotEmpty ? post.imagePaths.first : '',
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
      imagePaths: map['imagePath'].toString().isEmpty
          ? []
          : [map['imagePath'] as String],
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
        'imagePath': post.imagePaths.isNotEmpty ? post.imagePaths.first : '',
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