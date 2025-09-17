import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:ui';
import 'dart:convert'; // JSON encoding के लिए

// DrawingPoint क्लास ड्रॉइंग के हर पॉइंट की जानकारी रखेगी
class DrawingPoint {
  final Paint paint;
  final Offset offset;
  DrawingPoint({required this.offset, required this.paint});
}

// बाकी की क्लास (Highlight, Bookmark) वैसी ही रहेंगी...
class Highlight {
  final int id;
  final String noteFilePath;
  final int pageNumber;
  final String text;
  Highlight({required this.id, required this.noteFilePath, required this.pageNumber, required this.text});
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
    _database = await _initDB('notes_v5.db'); // DB का नाम बदला गया
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // पुरानी टेबल्स वैसी ही रहेंगी
    await db.execute('''
    CREATE TABLE highlights (id INTEGER PRIMARY KEY AUTOINCREMENT, noteFilePath TEXT NOT NULL, pageNumber INTEGER NOT NULL, text TEXT NOT NULL)
    ''');
    await db.execute('''
    CREATE TABLE bookmarks (id INTEGER PRIMARY KEY AUTOINCREMENT, noteFilePath TEXT NOT NULL, topicName TEXT NOT NULL, pageNumber INTEGER NOT NULL, UNIQUE(noteFilePath, pageNumber))
    ''');
    
    // FIX: ड्रॉइंग्स के लिए नई टेबल
    await db.execute('''
    CREATE TABLE drawings (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      noteFilePath TEXT NOT NULL,
      pageNumber INTEGER NOT NULL,
      points_json TEXT NOT NULL
    )
    ''');
  }

  // FIX: ड्रॉइंग को सेव करने के लिए नए फंक्शन
  Future<void> addDrawing(String noteFilePath, int pageNumber, List<DrawingPoint?> points) async {
    final db = await instance.database;
    // points को JSON स्ट्रिंग में कन्वर्ट करें
    List<Map<String, dynamic>> jsonPoints = points.map((p) {
      if (p == null) return {}; // Null points for line breaks
      return {
        'dx': p.offset.dx,
        'dy': p.offset.dy,
        'color': p.paint.color.value,
        'strokeWidth': p.paint.strokeWidth,
      };
    }).toList();
    
    await db.insert('drawings', {
      'noteFilePath': noteFilePath,
      'pageNumber': pageNumber,
      'points_json': json.encode(jsonPoints),
    });
  }

  // FIX: ड्रॉइंग को पाने के लिए नया फंक्शन
  Future<List<DrawingPoint?>> getDrawingsForPage(String noteFilePath, int pageNumber) async {
    final db = await instance.database;
    final maps = await db.query('drawings', where: 'noteFilePath = ? AND pageNumber = ?', whereArgs: [noteFilePath, pageNumber]);
    
    List<DrawingPoint?> points = [];
    for (var map in maps) {
      List<dynamic> jsonPoints = json.decode(map['points_json'] as String);
      for (var p in jsonPoints) {
        if (p.isEmpty) {
          points.add(null);
        } else {
          points.add(DrawingPoint(
            offset: Offset(p['dx'], p['dy']),
            paint: Paint()
              ..color = Color(p['color'])
              ..strokeWidth = p['strokeWidth']
              ..strokeCap = StrokeCap.round
              ..isAntiAlias = true,
          ));
        }
      }
    }
    return points;
  }

  // FIX: ड्रॉइंग को क्लियर करने के लिए नया फंक्शन
  Future<void> clearDrawingsOnPage(String noteFilePath, int pageNumber) async {
    final db = await instance.database;
    await db.delete('drawings', where: 'noteFilePath = ? AND pageNumber = ?', whereArgs: [noteFilePath, pageNumber]);
  }
  
  // बाकी के सभी फंक्शन वैसे ही रहेंगे...
  // ... (Highlight and Bookmark functions are omitted for brevity)
  Future<void> addHighlight(String noteFilePath, int pageNumber, String text) async { /* ... */ }
  Future<List<Highlight>> getAllHighlightsForNote(String noteFilePath) async { /* ... */ return []; }
  Future<void> toggleBookmark(String noteFilePath, String topicName, int pageNumber) async { /* ... */ }
  Future<bool> isPageBookmarked(String noteFilePath, int pageNumber) async { /* ... */ return false; }
  Future<List<Bookmark>> getBookmarksForSubject(List<String> topicFilePaths) async { /* ... */ return []; }
}
