// lib/features/practice/screens/practice_mcq_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/local_data_service.dart';
import '../../../helpers/database_helper.dart';

class PracticeMcqScreen extends StatefulWidget {
  final Map<String, dynamic> set;
  const PracticeMcqScreen({super.key, required this.set});

  @override
  State<PracticeMcqScreen> createState() => _PracticeMcqScreenState();
}

class _PracticeMcqScreenState extends State<PracticeMcqScreen> {
  final LocalDataService localDataService = LocalDataService();
  late List<Question> _questions;
  late PageController _pageController;
  final Map<int, String> _selectedAnswers = {};
  int _currentPage = 0;

  final dbHelper = DatabaseHelper.instance;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _questions = localDataService.getQuestionsForSet(
      widget.set['subject'] as String,
      widget.set['topic'] as String,
      widget.set['setIndex'] as int,
    );
    _pageController = PageController();
    _pageController.addListener(() {
      final newPage = _pageController.page?.round() ?? 0;
      if (newPage != _currentPage) {
        setState(() {
          _currentPage = newPage;
          _checkIfBookmarked();
        });
      }
    });
    _checkIfBookmarked();
  }

  Future<void> _checkIfBookmarked() async {
    if (_questions.isNotEmpty && _currentPage < _questions.length) {
      final isBookmarked = await dbHelper.isMcqBookmarked(_questions[_currentPage].questionText);
      if (mounted) {
        setState(() {
          _isBookmarked = isBookmarked;
        });
      }
    }
  }

  void _toggleMcqBookmark() async {
    if (_questions.isEmpty || _currentPage >= _questions.length) return;
    
    final question = _questions[_currentPage];
    if (_isBookmarked) {
      await dbHelper.removeMcqBookmark(question.questionText);
    } else {
      await dbHelper.addMcqBookmark(
          question, 
          widget.set['subject'] as String, 
          widget.set['topic'] as String
      );
    }
    _checkIfBookmarked();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  void _submitQuiz() {
    int score = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_selectedAnswers[i] == _questions[i].correctOption) {
        score++;
      }
    }
    context.go(
      '/score',
      extra: {
        'totalQuestions': _questions.length,
        'correctAnswers': score,
        'subject': widget.set['subject'],
        'topic': widget.set['topic'],
      },
    );
  }

  void _handleAnswer(int questionIndex, String option) {
    if (_selectedAnswers.containsKey(questionIndex)) return;

    final question = _questions[questionIndex];
    final isCorrect = option == question.correctOption;

    // FIX: अगर जवाब गलत है, तो प्रश्न को ऑटो-बुकमार्क करें
    if (!isCorrect) {
      dbHelper.addMcqBookmark(
        question,
        widget.set['subject'] as String,
        widget.set['topic'] as String
      ).then((_) {
        // UI को अपडेट करने के लिए बुकमार्क स्टेटस को फिर से चेक करें
        if (questionIndex == _currentPage) {
          _checkIfBookmarked();
        }
      });
    }

    setState(() {
      _selectedAnswers[questionIndex] = option;
    });
  }
  
  void _goToNextPage() {
    if (_currentPage < _questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
       _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Could not load questions.')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.teal,
      appBar: AppBar(
        title: Text('Set ${widget.set['setIndex']}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: Colors.white),
            tooltip: 'Bookmark Question',
            onPressed: _toggleMcqBookmark,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                final question = _questions[index];
                return _buildQuestionCard(question, index);
              },
            ),
          ),
          _buildBottomNavBar(),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Question question, int index) {
    final bool isAnswered = _selectedAnswers.containsKey(index);
    final String? selectedOption = _selectedAnswers[index];
    final optionLabels = ['A', 'B', 'C', 'D'];
    final options = [question.optionA, question.optionB, question.optionC, question.optionD];
    
    Color getOptionColor(String option) {
      if (!isAnswered) return Colors.transparent;
      if (option == question.correctOption) return Colors.green.withOpacity(0.3);
      if (option == selectedOption) return Colors.red.withOpacity(0.3);
      return Colors.transparent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Question ${index + 1}/${_questions.length}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Text(
                  question.questionText,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                
                const SizedBox(height: 24),

                ...options.asMap().entries.map((entry) {
                  int optionIndex = entry.key;
                  String optionText = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: InkWell(
                      onTap: () => _handleAnswer(index, optionText),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                          color: getOptionColor(optionText),
                        ),
                        child: Text(
                          '${optionLabels[optionIndex]}. $optionText',
                          style: const TextStyle(fontSize: 17),
                        ),
                      ),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 20),
                if (isAnswered)
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
                        fontSize: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildBottomNavBar() {
    bool isLastQuestion = _currentPage == _questions.length - 1;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: _currentPage == 0 ? null : _goToPreviousPage,
            child: const Text('Previous'),
          ),
          Text(
            '${_currentPage + 1}/${_questions.length}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          ElevatedButton(
            onPressed: isLastQuestion ? _submitQuiz : _goToNextPage,
            style: ElevatedButton.styleFrom(backgroundColor: isLastQuestion ? Colors.green : Colors.blue),
            child: Text(isLastQuestion ? 'Submit' : 'Next'),
          ),
        ],
      ),
    );
  }
}
