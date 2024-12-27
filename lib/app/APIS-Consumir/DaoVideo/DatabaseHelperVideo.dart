// lib/database/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelperVideo {
  static final DatabaseHelperVideo _instance = DatabaseHelperVideo._internal();
  static Database? _database;

  factory DatabaseHelperVideo() => _instance;

  DatabaseHelperVideo._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'likechat.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE videos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        videoPath TEXT NOT NULL,
        thumbnailPath TEXT,
        description TEXT,
        visibility TEXT DEFAULT 'public',
        allowDownloads INTEGER DEFAULT 1,
        allowStickers INTEGER DEFAULT 1,
        isPromotional INTEGER DEFAULT 0,
        viewCount INTEGER DEFAULT 0,
        likeCount INTEGER DEFAULT 0,
        shareCount INTEGER DEFAULT 0,
        createdAt TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }
}

// lib/models/video_model.dart
class Video {
  final int? id;
  final String videoPath;
  final String? thumbnailPath;
  final String? description;
  final String visibility;
  final bool allowDownloads;
  final bool allowStickers;
  final bool isPromotional;
  final int viewCount;
  final int likeCount;
  final int shareCount;
  final String? createdAt;

  Video({
    this.id,
    required this.videoPath,
    this.thumbnailPath,
    this.description,
    this.visibility = 'public',
    this.allowDownloads = true,
    this.allowStickers = true,
    this.isPromotional = false,
    this.viewCount = 0,
    this.likeCount = 0,
    this.shareCount = 0,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'videoPath': videoPath,
      'thumbnailPath': thumbnailPath,
      'description': description,
      'visibility': visibility,
      'allowDownloads': allowDownloads ? 1 : 0,
      'allowStickers': allowStickers ? 1 : 0,
      'isPromotional': isPromotional ? 1 : 0,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'shareCount': shareCount,
      'createdAt': createdAt,
    };
  }

  factory Video.fromMap(Map<String, dynamic> map) {
    return Video(
      id: map['id'],
      videoPath: map['videoPath'],
      thumbnailPath: map['thumbnailPath'],
      description: map['description'],
      visibility: map['visibility'],
      allowDownloads: map['allowDownloads'] == 1,
      allowStickers: map['allowStickers'] == 1,
      isPromotional: map['isPromotional'] == 1,
      viewCount: map['viewCount'],
      likeCount: map['likeCount'],
      shareCount: map['shareCount'],
      createdAt: map['createdAt'],
    );
  }
}

// lib/services/video_service.dart
class VideoService {
  final dbHelper = DatabaseHelperVideo();

  Future<int> insertVideo(Video video) async {
    final db = await dbHelper.database;
    return await db.insert('videos', video.toMap());
  }

  Future<Video?> getVideo(int id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'videos',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Video.fromMap(maps.first);
  }

  Future<List<Video>> getAllVideos({String? visibility}) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = visibility != null
        ? await db.query('videos', where: 'visibility = ?', whereArgs: [visibility])
        : await db.query('videos');

    return List.generate(maps.length, (i) => Video.fromMap(maps[i]));
  }

  Future<int> updateVideo(Video video) async {
    final db = await dbHelper.database;
    return await db.update(
      'videos',
      video.toMap(),
      where: 'id = ?',
      whereArgs: [video.id],
    );
  }

  Future<int> deleteVideo(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'videos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> incrementCounter(int id, String counterType) async {
    final db = await dbHelper.database;
    return await db.rawUpdate(
      'UPDATE videos SET $counterType = $counterType + 1 WHERE id = ?',
      [id],
    );
  }
}