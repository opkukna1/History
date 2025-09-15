import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/local_data_service.dart';

class TestMcqScreen extends StatefulWidget {
  final Map<String, dynamic> testSettings;
  const TestMcqScreen({super.key, required this.testSettings});

  @override
  State<TestMcqScreen> createState() => _TestMcqScreenState();
}

class _TestMcqScreenState extends State<TestMcqScreen> {
  late final List<Map<String, dynamic>> _questions;
  late final PageController _pageController;
  final List<String?> _userAnswers = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // For now, we get all questions for the topic and take the required count
    // Later this will be smarter (difficulty, etc.)
    _questions = localDataService
        .getQuestionsForSet(widget.testSettings['topic'] as String, 0) // Getting Set 1 for now
        .take(widget.testSettings['count'] as int)
        .toList();
    _userAnswers.length = _questions.length;
  }

  void _submitTest() {
    int score = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_userAnswers[i] == _questions[i]['CorrectAnswer']) {
        score++;
      }
    }
    final results = {'score': score, 'total': _questions.length};
    context.go('/test_score', extra: results);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.testSettings['topic']} Test'),
      ),
      body: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _questions.length,
        itemBuilder: (context, index) {
          final questionData = _questions[index];
          final options = [
            questionData['OptionA'], questionData['OptionB'],
            questionData['OptionC'], questionData['OptionD'],
          ];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Question ${index + 1}/${_questions.length}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  questionData['Question'] as String,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                ...options.map((option) {
                  return Card(
                    color: _userAnswers[index] == option
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,
                    child: ListTile(
                      title: Text(option.toString()),
                      onTap: () {
                        setState(() {
                          _userAnswers[index] = option.toString();
                        });
                      },
                    ),
                  );
                }).toList(),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    bool isLastQuestion = index == _questions.length - 1;
                    if (isLastQuestion) {
                      _submitTest();
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    }
                  },
                  child: Text(index == _questions.length - 1 ? 'Submit Test' : 'Next Question'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
