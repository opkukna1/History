import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:ui'; // Rect के लिए

class Highlight {
  final int id;
  final String noteFilePath;
  final int pageNumber;
  final Rect rect;
  final String color;
  final String text;

  Highlight({
    required this.id,
    required this.noteFilePath,
    required this.pageNumber,
    required this.rect,
    required this.color,
    required this.text,
  });
}

class Bookmark {
    final int id;
    final String noteFilePath;
    final String topicName;
    final int pageNumber;

    Bookmark({required this.id, required this.noteFilePath, required this.topicName, required this.pageNumber});
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes_v3.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE highlights (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      noteFilePath TEXT NOT NULL,
      pageNumber INTEGER NOT NULL,
      rect_left REAL NOT NULL,
      rect_top REAL NOT NULL,
      rect_width REAL NOT NULL,
      rect_height REAL NOT NULL,
      color TEXT NOT NULL,
      text TEXT NOT NULL
    )
    ''');
    await db.execute('''
    CREATE TABLE bookmarks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      noteFilePath TEXT NOT NULL,
      topicName TEXT NOT NULL,
      pageNumber INTEGER NOT NULL,
      UNIQUE(noteFilePath, pageNumber)
    )
    ''');
  }

  Future<void> addHighlight(String noteFilePath, int pageNumber, Rect rect, String color, String text) async {
    final db = await instance.database;
    await db.insert('highlights', {
      'noteFilePath': noteFilePath,
      'pageNumber': pageNumber,
      'rect_left': rect.left,
      'rect_top': rect.top,
      'rect_width': rect.width,
      'rect_height': rect.height,
      'color': color,
      'text': text,
    });
  }

  Future<List<Highlight>> getHighlightsForPage(String noteFilePath, int pageNumber) async {
    final db = await instance.database;
    final maps = await db.query('highlights', where: 'noteFilePath = ? AND pageNumber = ?', whereArgs: [noteFilePath, pageNumber]);
    return maps.map((map) => Highlight(
      id: map['id'] as int,
      noteFilePath: map['noteFilePath'] as String,
      pageNumber: map['pageNumber'] as int,
      rect: Rect.fromLTWH(map['rect_left'] as double, map['rect_top'] as double, map['rect_width'] as double, map['rect_height'] as double),
      color: map['color'] as String,
      text: map['text'] as String,
    )).toList();
  }

  Future<List<Highlight>> getAllHighlightsForNote(String noteFilePath) async {
    final db = await instance.database;
    final maps = await db.query('highlights', where: 'noteFilePath = ?', whereArgs: [noteFilePath], orderBy: 'pageNumber');
    return maps.map((map) => Highlight(
      id: map['id'] as int,
      noteFilePath: map['noteFilePath'] as String,
      pageNumber: map['pageNumber'] as int,
      rect: Rect.fromLTWH(map['rect_left'] as double, map['rect_top'] as double, map['rect_width'] as double, map['rect_height'] as double),
      color: map['color'] as String,
      text: map['text'] as String,
    )).toList();
  }

  Future<void> clearHighlightsOnPage(String noteFilePath, int pageNumber) async {
    final db = await instance.database;
    await db.delete('highlights', where: 'noteFilePath = ? AND pageNumber = ?', whereArgs: [noteFilePath, pageNumber]);
  }
  
  Future<void> toggleBookmark(String noteFilePath, String topicName, int pageNumber) async {
    final db = await instance.database;
    final isBookmarked = await isPageBookmarked(noteFilePath, pageNumber);
    if (isBookmarked) {
      await db.delete('bookmarks', where: 'noteFilePath = ? AND pageNumber = ?', whereArgs: [noteFilePath, pageNumber]);
    } else {
      await db.insert('bookmarks', {'noteFilePath': noteFilePath, 'topicName': topicName, 'pageNumber': pageNumber});
    }
  }

  Future<bool> isPageBookmarked(String noteFilePath, int pageNumber) async {
    final db = await instance.database;
    final maps = await db.query('bookmarks', where: 'noteFilePath = ? AND pageNumber = ?', whereArgs: [noteFilePath, pageNumber]);
    return maps.isNotEmpty;
  }
  
  Future<List<Bookmark>> getBookmarksForSubject(List<String> topicFilePaths) async {
    final db = await instance.database;
    if (topicFilePaths.isEmpty) return [];
    
    final placeholders = ('?' * topicFilePaths.length).split('').join(',');
    final maps = await db.query('bookmarks', where: 'noteFilePath IN ($placeholders)', whereArgs: topicFilePaths);
    
    return maps.map((map) => Bookmark(
      id: map['id'] as int,
      noteFilePath: map['noteFilePath'] as String,
      topicName: map['topicName'] as String,
      pageNumber: map['pageNumber'] as int,
    )).toList();
  }
}
