// lib/features/practice/screens/practice_mcq_screen.dart

import 'package:flutter/material.dart';
import '../../../core/local_data_service.dart';

// FIX: Constructor now correctly takes a 'set' map
class PracticeMcqScreen extends StatefulWidget {
  final Map<String, dynamic> set;
  const PracticeMcqScreen({super.key, required this.set});

  @override
  State<PracticeMcqScreen> createState() => _PracticeMcqScreenState();
}

class _PracticeMcqScreenState extends State<PracticeMcqScreen> {
  // FIX: Re-establish the connection to the data service
  final LocalDataService localDataService = LocalDataService();
  List<Question> _questions = [];
  int _currentIndex = 0;
  
  @override
  void initState() {
    super.initState();
    // FIX: Get data from the 'set' map passed by the router
    final subject = widget.set['subject'] as String;
    final topic = widget.set['topic'] as String;
    final setIndex = widget.set['setIndex'] as int;
    _questions = localDataService.getQuestionsForSet(subject, topic, setIndex);
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Set ${widget.set['setIndex']} - Question ${_currentIndex + 1}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(question.questionText, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            // ... (Rest of your options and button widgets)
          ],
        ),
      ),
    );
  }
}

