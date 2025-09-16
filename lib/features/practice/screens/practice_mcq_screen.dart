// lib/features/practice/screens/practice_mcq_screen.dart

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
  final LocalDataService localDataService = LocalDataService();
  List<Question> _questions = [];
  int _currentIndex = 0;
  int _score = 0;

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
      _submitQuiz();
    }
  }

  void _handlePrevious() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _isAnswered = false;
        _selectedOption = null;
      });
    }
  }

  void _handleAnswer(String option) {
    if (_isAnswered) return;
    setState(() {
      _selectedOption = option;
      _isAnswered = true;
      if (option == _questions[_currentIndex].correctOption) {
        _score++;
      }
    });
  }
  
  void _submitQuiz() {
    context.go(
      '/score',
      extra: {
        'totalQuestions': _questions.length,
        'correctAnswers': _score,
      },
    );
  }

  Future<bool> _onWillPop() async {
    return (await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('Do you want to exit the quiz?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    )) ?? false;
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

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.teal,
        appBar: AppBar(
          title: Text('Set ${widget.set['setIndex']}'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Question ${_currentIndex + 1}/${_questions.length}',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          question.questionText,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        ..._buildOptions(question),
                        const Spacer(),
                        if (_isAnswered)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Correct Answer is: ${question.correctOption}',
                              style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              _buildBottomNavBar(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildOptions(Question question) {
    final options = [
      question.optionA,
      question.optionB,
      question.optionC,
      question.optionD
    ];
    return options.map((option) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: InkWell(
          onTap: () => _handleAnswer(option),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: _getOptionColor(option, question.correctOption),
            ),
            child: Text(option, style: const TextStyle(fontSize: 16)),
          ),
        ),
      );
    }).toList();
  }

  Color _getOptionColor(String option, String correctAnswer) {
    if (!_isAnswered) return Colors.transparent;
    if (option == correctAnswer) return Colors.green.withOpacity(0.3);
    if (option == _selectedOption) return Colors.red.withOpacity(0.3);
    return Colors.transparent;
  }
  
  Widget _buildBottomNavBar() {
    bool isLastQuestion = _currentIndex == _questions.length - 1;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: _currentIndex == 0 ? null : _handlePrevious,
            child: const Text('Previous'),
          ),
          Text(
            '${_currentIndex + 1}/${_questions.length}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          ElevatedButton(
            onPressed: !_isAnswered ? null : (isLastQuestion ? _submitQuiz : _handleNext),
            style: ElevatedButton.styleFrom(backgroundColor: isLastQuestion ? Colors.green : Colors.blue),
            child: Text(isLastQuestion ? 'Submit' : 'Next'),
          ),
        ],
      ),
    );
  }
}
