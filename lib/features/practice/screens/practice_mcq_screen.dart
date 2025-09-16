// lib/features/practice/screens/practice_mcq_screen.dart

import 'package:flutter/material.dart';
import '../../../core/local_data_service.dart';

class PracticeMcqScreen extends StatefulWidget {
  final Map<String, dynamic> set;
  const PracticeMcqScreen({super.key, required this.set});

  @override
  State<PracticeMcqScreen> createState() => _PracticeMcqScreenState();
}

class _PracticeMcqScreenState extends State<PracticeMcqScreen> {
  final LocalDataService localDataService = LocalDataService();
  List<Question> _questions = [];
  int _currentIndex = 0;

  String? _selectedOption;
  bool _isAnswered = false;

  @override
  void initState() {
    super.initState();
    final subject = widget.set['subject'] as String;
    final topic = widget.set['topic'] as String;
    final setIndex = widget.set['setIndex'] as int;
    _questions = localDataService.getQuestionsForSet(subject, topic, setIndex);
  }

  void _handleNext() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _isAnswered = false;
        _selectedOption = null;
      });
    } else {
      // Optional: Show a message when the set is complete
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Set complete!')),
      );
    }
  }

  void _handleAnswer(String option) {
    if (_isAnswered) return; // Prevent changing answer
    setState(() {
      _selectedOption = option;
      _isAnswered = true;
    });
  }

  Color _getOptionColor(String option, String correctAnswer) {
    if (!_isAnswered) {
      return Colors.grey.shade200; // Default color
    }
    if (option == correctAnswer) {
      return Colors.green.shade200; // Correct answer
    }
    if (option == _selectedOption && option != correctAnswer) {
      return Colors.red.shade200; // Incorrectly selected answer
    }
    return Colors.grey.shade200; // Other options
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Could not load questions.')),
      );
    }

    final question = _questions[_currentIndex];
    final options = [
      question.optionA,
      question.optionB,
      question.optionC,
      question.optionD
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Set ${widget.set['setIndex']} - Question ${_currentIndex + 1}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Question Text
            Text(
              question.questionText,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Options List
            ...options.map((option) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Material(
                   color: _getOptionColor(option, question.correctOption),
                   borderRadius: BorderRadius.circular(12),
                   child: InkWell(
                      onTap: () => _handleAnswer(option),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Text(option, style: const TextStyle(fontSize: 16)),
                      ),
                   ),
                ),
              );
            }).toList(),
            
            const Spacer(), // Pushes the button to the bottom

            // Next Button
            ElevatedButton(
              onPressed: _handleNext,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Next'),
            ),
             const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
