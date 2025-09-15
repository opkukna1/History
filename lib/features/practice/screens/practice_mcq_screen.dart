import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/dummy_data.dart';

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
    _questions = DummyData.mcqs
        .where((mcq) => mcq['setId'] == widget.set['id'])
        .toList();
  }

  void _checkAnswer(String option) {
    setState(() {
      _selectedOption = option;
      _showAnswer = true;
      if (option == _questions[_currentIndex]['correctAnswer']) {
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
        // Test finished, go to score screen
        final results = {
          'score': _score,
          'total': _questions.length,
        };
        context.go('/score', extra: results);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final questionData = _questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.set['name']} - Question ${_currentIndex + 1}/${_questions.length}'),
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
                bool isCorrect = option == questionData['correctAnswer'];
                bool isSelected = option == _selectedOption;

                Color? tileColor;
                if (_showAnswer) {
                  if (isCorrect) {
                    tileColor = Colors.green.shade100;
                  } else if (isSelected) {
                    tileColor = Colors.red.shade100;
                  }
                }

                return Card(
                  color: tileColor,
                  child: ListTile(
                    title: Text(option),
                    onTap: _showAnswer ? null : () => _checkAnswer(option),
                  ),
                );
              },
            ),
            const Spacer(),
            if (_showAnswer)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _nextQuestion,
                child: Text(_currentIndex == _questions.length - 1 ? 'Submit' : 'Next'),
              ),
          ],
        ),
      ),
    );
  }
}
