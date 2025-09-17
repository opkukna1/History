import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
// ... (अन्य इम्पोर्ट्स)

// ... (Highlight, Bookmark, DrawingPoint क्लास वैसी ही रहेंगी) ...

// FIX: MCQ बुकमार्क के लिए नई क्लास
class McqBookmark {
  final int id;
  final String subject;
  final String topic;
  final String questionText;
  final String correctOption;
  
  McqBookmark({
    required this.id,
    required this.subject,
    required this.topic,
    required this.questionText,
    required this.correctOption,
  });
}


class DatabaseHelper {
  // ... (database, _initDB फंक्शन वैसे ही रहेंगे) ...
  _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'notes_v8.db'); // DB का नाम बदला गया
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // ... (highlights, bookmarks, drawings टेबल वैसी ही रहेंगी) ...
    
    // FIX: MCQ बुकमार्क के लिए नई टेबल
    await db.execute('''
    CREATE TABLE mcq_bookmarks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      subject TEXT NOT NULL,
      topic TEXT NOT NULL,
      questionText TEXT NOT NULL UNIQUE,
      correctOption TEXT NOT NULL
    )
    ''');
  }

  // FIX: MCQ बुकमार्क के लिए नए फंक्शन
  Future<int> addMcqBookmark(Question question, String subject, String topic) async {
    final db = await instance.database;
    return await db.insert('mcq_bookmarks', {
      'subject': subject,
      'topic': topic,
      'questionText': question.questionText,
      'correctOption': question.correctOption,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<int> removeMcqBookmark(String questionText) async {
    final db = await instance.database;
    return await db.delete('mcq_bookmarks', where: 'questionText = ?', whereArgs: [questionText]);
  }

  Future<bool> isMcqBookmarked(String questionText) async {
    final db = await instance.database;
    final maps = await db.query('mcq_bookmarks', where: 'questionText = ?', whereArgs: [questionText]);
    return maps.isNotEmpty;
  }

  Future<List<McqBookmark>> getAllMcqBookmarks() async {
    final db = await instance.database;
    final maps = await db.query('mcq_bookmarks', orderBy: 'subject, topic');
    return maps.map((map) => McqBookmark(
      id: map['id'] as int,
      subject: map['subject'] as String,
      topic: map['topic'] as String,
      questionText: map['questionText'] as String,
      correctOption: map['correctOption'] as String,
    )).toList();
  }

  // ... (बाकी के सभी फंक्शन वैसे ही रहेंगे) ...
}
