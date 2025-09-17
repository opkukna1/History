// lib/helpers/database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../core/local_data_service.dart';

class Bookmark {
  final int id;
  final String noteFilePath;
  final String topicName;
  final int pageNumber;
  Bookmark({required this.id, required this.noteFilePath, required this.topicName, required this.pageNumber});
}

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
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes_v8.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('CREATE TABLE mcq_bookmarks (id INTEGER PRIMARY KEY AUTOINCREMENT, subject TEXT NOT NULL, topic TEXT NOT NULL, questionText TEXT NOT NULL UNIQUE, correctOption TEXT NOT NULL)');
    await db.execute('CREATE TABLE bookmarks (id INTEGER PRIMARY KEY AUTOINCREMENT, noteFilePath TEXT NOT NULL, topicName TEXT NOT NULL, pageNumber INTEGER NOT NULL, UNIQUE(noteFilePath, pageNumber))');
  }
  
  // MCQ Bookmark Functions
  Future<int> addMcqBookmark(Question question, String subject, String topic) async {
    final db = await instance.database;
    return await db.insert('mcq_bookmarks', {'subject': subject, 'topic': topic, 'questionText': question.questionText, 'correctOption': question.correctOption}, conflictAlgorithm: ConflictAlgorithm.ignore);
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
    return maps.map((map) => McqBookmark(id: map['id'] as int, subject: map['subject'] as String, topic: map['topic'] as String, questionText: map['questionText'] as String, correctOption: map['correctOption'] as String)).toList();
  }

  // Note Bookmark Functions
  Future<List<Bookmark>> getAllBookmarks() async {
    final db = await instance.database;
    final maps = await db.query('bookmarks', orderBy: 'topicName');
    return maps.map((map) => Bookmark(id: map['id'] as int, noteFilePath: map['noteFilePath'] as String, topicName: map['topicName'] as String, pageNumber: map['pageNumber'] as int)).toList();
  }
  
  // FIX: यह फंक्शन वापस जोड़ा गया
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
}
