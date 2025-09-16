import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'dart:developer' as dev;

class Question {
  final String subject;
  final String topic;
  final String questionText;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctOption;

  Question({
    required this.subject,
    required this.topic,
    required this.questionText,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctOption,
  });

  @override
  String toString() {
    return 'Question{subject: $subject, topic: $topic, questionText: $questionText}';
  }
}

class LocalDataService {
  static final LocalDataService _instance = LocalDataService._internal();
  factory LocalDataService() => _instance;

  LocalDataService._internal();

  List<Question> _allQuestions = [];
  bool _isInitialized = false;

  Future<void> loadQuestions() async {
    if (_isInitialized) return;
    try {
      final rawData = await rootBundle.loadString('assets/question_bank.csv');
      List<List<dynamic>> listData = const CsvToListConverter(eol: '\n').convert(rawData);
      
      _allQuestions = []; // Clear previous data
      if (listData.length > 1) {
        listData.removeAt(0); // Remove header
        for (var row in listData) {
          if (row.length == 8) {
             _allQuestions.add(Question(
              subject: row[0].toString().trim(),
              topic: row[1].toString().trim(),
              questionText: row[2].toString().trim(),
              optionA: row[3].toString().trim(),
              optionB: row[4].toString().trim(),
              optionC: row[5].toString().trim(),
              optionD: row[6].toString().trim(),
              correctOption: row[7].toString().trim(),
            ));
          }
        }
      }
      _isInitialized = true;
      dev.log('CSV Loading Complete: ${_allQuestions.length} questions loaded.');
    } catch (e) {
      dev.log('Error loading CSV: $e');
      _allQuestions = [];
    }
  }

  // --- EXISTING FUNCTIONS ---
  List<String> getSubjects() {
    if (!_isInitialized) return [];
    return _allQuestions.map((q) => q.subject).toSet().toList();
  }

  List<String> getTopicsForSubject(String subject) {
    if (!_isInitialized) return [];
    return _allQuestions
        .where((q) => q.subject.trim().toLowerCase() == subject.trim().toLowerCase())
        .map((q) => q.topic)
        .toSet()
        .toList();
  }

  List<Question> getQuestionsForSet(String subject, String topic, int setNumber) {
    if (!_isInitialized) return [];
    final questionsForTopic = _allQuestions
        .where((q) =>
            q.subject.trim().toLowerCase() == subject.trim().toLowerCase() &&
            q.topic.trim().toLowerCase() == topic.trim().toLowerCase())
        .toList();

    int startIndex = (setNumber - 1) * 10;
    int endIndex = startIndex + 10;
    if (startIndex >= questionsForTopic.length) {
      return [];
    }
    if (endIndex > questionsForTopic.length) {
      endIndex = questionsForTopic.length;
    }
    return questionsForTopic.sublist(startIndex, endIndex);
  }

  // --- NEW FORENSIC FUNCTION ---
  List<Question> getQuestionsForTopicXRay(String subject, String topic) {
    dev.log('FORENSICS: Searching for Subject="$subject", Topic="$topic"');
    if (!_isInitialized) {
      dev.log('FORENSICS: Data not initialized.');
      return [];
    }
    
    final matchingQuestions = _allQuestions
        .where((q) =>
            q.subject.trim().toLowerCase() == subject.trim().toLowerCase() &&
            q.topic.trim().toLowerCase() == topic.trim().toLowerCase())
        .toList();
    
    dev.log('FORENSICS: Found ${matchingQuestions.length} matching questions.');
    return matchingQuestions;
  }
}
