import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/local_data_service.dart';

class PracticeMcqScreen extends StatefulWidget {
  final Map<String, dynamic> set;
  const PracticeMcqScreen({super.key, required this.set});
  @override
  State<PracticeMcqScreen> createState() => _PracticeMcqScreenState();
}

class _PracticeMcqScreenState extends State<PracticeMcqScreen> {
  late final List<Map<String, dynamic>> _questions;
  int _currentIndex = 0;
  String? _selectedOption;
  bool _showAnswer = false;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _questions = localDataService.getQuestionsForSet(widget.set['topicId'] as String, widget.set['setIndex'] as int);
  }

  String _getData(Map<String, dynamic> data, String key) {
    if (data.containsKey(key)) return data[key].toString();
    return 'Data Not Found';
  }

  void _checkAnswer(String option) {
    setState(() {
      _selectedOption = option;
      _showAnswer = true;
      if (option == _getData(_questions[_currentIndex], 'CorrectOption')) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      if (_currentIndex < _questions.length - 1) {
        _currentIndex++;
        _selectedOption = null;
        _showAnswer = false;
      } else {
        final results = {'score': _score, 'total': _questions.length};
        context.go('/score', extra: results);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.set['name'] as String)),
        body: const Center(child: Text('No questions found for this set.'))
      );
    }
    
    final questionData = _questions[_currentIndex];
    final options = [
      _getData(questionData, 'OptionA'), _getData(questionData, 'OptionB'),
      _getData(questionData, 'OptionC'), _getData(questionData, 'OptionD'),
    ];

    return Scaffold(
      appBar: AppBar(title: Text('${widget.set['name']} - Q ${_currentIndex + 1}/${_questions.length}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_getData(questionData, 'Question'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ...options.map((option) {
                bool isCorrect = option == _getData(questionData, 'CorrectOption');
                bool isSelected = option == _selectedOption;
                Color? tileColor;
                if (_showAnswer) {
                  if (isCorrect) tileColor = Colors.green.shade100;
                  else if (isSelected) tileColor = Colors.red.shade100;
                }
                return Card(
                  color: tileColor,
                  child: ListTile(title: Text(option), onTap: _showAnswer ? null : () => _checkAnswer(option))
                );
            }).toList(),
            const Spacer(),
            if (_showAnswer)
              ElevatedButton(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed: _nextQuestion,
                child: Text(_currentIndex == _questions.length - 1 ? 'Submit' : 'Next'),
              ),
          ],
        ),
      ),
    );
  }
}
