import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Highlight क्लास से Rect (जगह) को हटा दिया गया
class Highlight {
  final int id;
  final String noteFilePath;
  final int pageNumber;
  final String text;

  Highlight({
    required this.id,
    required this.noteFilePath,
    required this.pageNumber,
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
    _database = await _initDB('notes_v4.db'); // DB का नाम बदला गया
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // highlights टेबल से rect वाले कॉलम हटा दिए गए
    await db.execute('''
    CREATE TABLE highlights (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      noteFilePath TEXT NOT NULL,
      pageNumber INTEGER NOT NULL,
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

  // addHighlight फंक्शन को अपडेट किया गया
  Future<void> addHighlight(String noteFilePath, int pageNumber, String text) async {
    final db = await instance.database;
    await db.insert('highlights', {
      'noteFilePath': noteFilePath,
      'pageNumber': pageNumber,
      'text': text,
    });
  }
  
  // getAllHighlightsForNote फंक्शन को अपडेट किया गया
  Future<List<Highlight>> getAllHighlightsForNote(String noteFilePath) async {
    final db = await instance.database;
    final maps = await db.query('highlights', where: 'noteFilePath = ?', whereArgs: [noteFilePath], orderBy: 'pageNumber');
    return maps.map((map) => Highlight(
      id: map['id'] as int,
      noteFilePath: map['noteFilePath'] as String,
      pageNumber: map['pageNumber'] as int,
      text: map['text'] as String,
    )).toList();
  }

  Future<void> clearAllHighlights(String noteFilePath) async {
    final db = await instance.database;
    await db.delete('highlights', where: 'noteFilePath = ?', whereArgs: [noteFilePath]);
  }
  
  // बाकी के बुकमार्क फंक्शन वैसे ही रहेंगे
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
