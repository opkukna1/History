import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'dart:math';

final localDataService = LocalDataService();

class LocalDataService {
  List<Map<String, dynamic>> _allQuestions = [];
  bool _isDataLoaded = false;

  Future<void> loadData() async {
    if (_isDataLoaded) return;
    final rawData = await rootBundle.loadString('assets/question_bank.csv');
    List<List<dynamic>> listData = CsvToListConverter(eol: '\n', shouldParseNumbers: false).convert(rawData);
    _allQuestions = [];
    if (listData.length > 1) {
      final headers = listData[0].map((e) => e.toString().trim()).toList();
      for (var i = 1; i < listData.length; i++) {
        final row = listData[i];
        if (row.length == headers.length) {
          final questionMap = <String, dynamic>{};
          for (var j = 0; j < headers.length; j++) {
            var value = row[j];
            questionMap[headers[j]] = value is String ? value.trim() : value;
          }
          _allQuestions.add(questionMap);
        }
      }
    }
    _isDataLoaded = true;
  }
  
  List<Map<String, dynamic>> getSubjects() {
    if(!_isDataLoaded) return [];
    final subjectNames = _allQuestions.map((q) => q['Subject']?.toString() ?? 'N/A').toSet().toList();
    return subjectNames.map((name) => {'id': name, 'name': name}).toList();
  }

  List<Map<String, dynamic>> getTopics(String subjectName) {
    if(!_isDataLoaded) return [];
    final topicNames = _allQuestions.where((q) => q['Subject'] == subjectName).map((q) => q['Topic']?.toString() ?? 'N/A').toSet().toList();
    return topicNames.map((name) => {'id': name, 'name': name, 'subjectId': subjectName}).toList();
  }
  
  List<Map<String, dynamic>> getSetsForTopic(String topicName) {
    if(!_isDataLoaded) return [];
    final questionsForTopic = _allQuestions.where((q) => q['Topic'] == topicName).toList();
    if (questionsForTopic.isEmpty) return [];
    List<Map<String, dynamic>> sets = [];
    int setSize = 25;
    int totalSets = (questionsForTopic.length / setSize).ceil();
    for (int i = 0; i < totalSets; i++) {
      int questionCount = min(setSize, questionsForTopic.length - (i * setSize));
      sets.add({'id': 'set${i + 1}', 'name': 'Set ${i + 1}', 'topicId': topicName, 'setIndex': i, 'questionCount': questionCount});
    }
    return sets;
  }

  List<Map<String, dynamic>> getQuestionsForSet(String topicName, int setIndex) {
    if(!_isDataLoaded) return [];
    final questionsForTopic = _allQuestions.where((q) => q['Topic'] == topicName).toList();
    int setSize = 25;
    int startIndex = setIndex * setSize;
    int endIndex = min(startIndex + setSize, questionsForTopic.length);
    if (startIndex >= questionsForTopic.length) return [];
    return questionsForTopic.sublist(startIndex, endIndex);
  }
}
