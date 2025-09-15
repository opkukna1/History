import 'package.flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/dummy_data.dart';

class TestMcqScreen extends StatefulWidget {
  final Map<String, dynamic> testSettings;
  const TestMcqScreen({super.key, required this.testSettings});

  @override
  State<TestMcqScreen> createState() => _TestMcqScreenState();
}

class _TestMcqScreenState extends State<TestMcqScreen> {
  late final List<Map<String, dynamic>> _questions;
  late final List<String?> _userAnswers;
  int _currentIndex = 0;
  
  @override
  void initState() {
    super.initState();
    // Abhi hum dummy data se random questions le rahe hain
    final allQuestions = List<Map<String, dynamic>>.from(DummyData.mcqs);
    allQuestions.shuffle();
    _questions = allQuestions.take(widget.testSettings['count'] as int).toList();
    _userAnswers = List.filled(_questions.length, null);
  }

  void _onOptionSelected(String option) {
    setState(() {
      _userAnswers[_currentIndex] = option;
    });
  }

  void _nextOrSubmit() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      // Test finished, calculate score and navigate
      int score = 0;
      for (int i = 0; i < _questions.length; i++) {
        if (_userAnswers[i] == _questions[i]['correctAnswer']) {
          score++;
        }
      }
      final results = {'score': score, 'total': _questions.length};
      context.go('/test_score', extra: results);
    }
  }

  @override
  Widget build(BuildContext context) {
    final questionData = _questions[_currentIndex];
    final isLastQuestion = _currentIndex == _questions.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text('Test - Question ${_currentIndex + 1}/${_questions.length}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              questionData['question'] as String,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ...List.generate(
              (questionData['options'] as List).length,
              (index) {
                final option = (questionData['options'] as List)[index];
                bool isSelected = _userAnswers[_currentIndex] == option;
                return Card(
                  color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
                  child: ListTile(
                    title: Text(option),
                    onTap: () => _onOptionSelected(option),
                  ),
                );
              },
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _userAnswers[_currentIndex] == null ? null : _nextOrSubmit,
              child: Text(isLastQuestion ? 'Submit Test' : 'Next Question'),
            ),
          ],
        ),
      ),
    );
  }
}
