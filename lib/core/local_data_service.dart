import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'dart:math';

// Yah class ab automatic sets banayegi
class LocalDataService {
  List<Map<String, dynamic>> _allQuestions = [];
  bool _isDataLoaded = false;

  Future<void> loadData() async {
    if (_isDataLoaded) return; // Agar data pehle se loaded hai to dobara mat karo

    final rawData = await rootBundle.loadString('assets/question_bank.csv');
    List<List<dynamic>> listData = const CsvToListConverter(eol: '\n').convert(rawData);
    
    _allQuestions = [];
    if (listData.length > 1) {
      final headers = listData[0].map((e) => e.toString().trim()).toList();
      for (var i = 1; i < listData.length; i++) {
        final row = listData[i];
        if (row.length == headers.length) { // Ensure row is not malformed
          final questionMap = <String, dynamic>{};
          for (var j = 0; j < headers.length; j++) {
            questionMap[headers[j]] = row[j];
          }
          _allQuestions.add(questionMap);
        }
      }
    }
    _isDataLoaded = true;
    print('CSV se ${_allQuestions.length} sawal load ho gaye!');
  }

  List<Map<String, dynamic>> getSubjects() {
    final subjectNames = _allQuestions.map((q) => q['Subject'] as String).toSet().toList();
    return subjectNames.map((name) => {'id': name, 'name': name}).toList();
  }

  List<Map<String, dynamic>> getTopics(String subjectName) {
     final topicNames = _allQuestions
        .where((q) => q['Subject'] == subjectName)
        .map((q) => q['Topic'] as String)
        .toSet()
        .toList();
    return topicNames.map((name) => {'id': name, 'name': name, 'subjectId': subjectName}).toList();
  }

  // YAH HAI NAYA JAADU WALA FUNCTION
  List<Map<String, dynamic>> getSetsForTopic(String topicName) {
    final questionsForTopic = _allQuestions.where((q) => q['Topic'] == topicName).toList();
    if (questionsForTopic.isEmpty) return [];

    List<Map<String, dynamic>> sets = [];
    int setSize = 25;
    // Calculate how many sets we need
    int totalSets = (questionsForTopic.length / setSize).ceil();

    for (int i = 0; i < totalSets; i++) {
      int questionCount = min(setSize, questionsForTopic.length - (i * setSize));
      sets.add({
        'id': 'set${i + 1}',
        'name': 'Set ${i + 1}',
        'topicId': topicName,
        'setIndex': i, // Yah bahut zaroori hai
        'questionCount': questionCount,
      });
    }
    return sets;
  }

  // Yah function ek khas set ke liye questions dega
  List<Map<String, dynamic>> getQuestionsForSet(String topicName, int setIndex) {
    final questionsForTopic = _allQuestions.where((q) => q['Topic'] == topicName).toList();
    int setSize = 25;
    
    int startIndex = setIndex * setSize;
    int endIndex = min(startIndex + setSize, questionsForTopic.length);

    if (startIndex >= questionsForTopic.length) return [];
    
    return questionsForTopic.sublist(startIndex, endIndex);
  }
}
