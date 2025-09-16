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
  late List<Question> _questions;
  
  // FIX: PageView को कंट्रोल करने के लिए
  late PageController _pageController;

  // FIX: हर सवाल का जवाब स्टोर करने के लिए
  // Key: सवाल का index, Value: चुना गया ऑप्शन
  final Map<int, String> _selectedAnswers = {};
  
  // FIX: वर्तमान पेज का index रखने के लिए
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _questions = localDataService.getQuestionsForSet(
      widget.set['subject'] as String,
      widget.set['topic'] as String,
      widget.set['setIndex'] as int,
    );
    
    _pageController = PageController();

    // पेज बदलने पर _currentPage को अपडेट करने के लिए Listener
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  void _submitQuiz() {
    int score = 0;
    // FIX: अंत में सभी जवाबों को चेक करके स्कोर की गणना करें
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
    // अगर उस सवाल का जवाब पहले से दिया है, तो कुछ न करें
    if (_selectedAnswers.containsKey(questionIndex)) return;

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
      ),
      body: Column(
        children: [
          // FIX: सवालों को स्वाइप करने के लिए PageView
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

  // एक सवाल और उसके विकल्पों को दिखाने वाला विजेट
  Widget _buildQuestionCard(Question question, int index) {
    final bool isAnswered = _selectedAnswers.containsKey(index);
    final String? selectedOption = _selectedAnswers[index];
    
    Color getOptionColor(String option) {
      if (!isAnswered) return Colors.transparent;
      if (option == question.correctOption) return Colors.green.withOpacity(0.3);
      if (option == selectedOption) return Colors.red.withOpacity(0.3);
      return Colors.transparent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Question ${index + 1}/${_questions.length}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    question.questionText,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ...[question.optionA, question.optionB, question.optionC, question.optionD].map((option) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: InkWell(
                    onTap: () => _handleAnswer(index, option),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        color: getOptionColor(option),
                      ),
                      child: Text(option, style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 10),
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
