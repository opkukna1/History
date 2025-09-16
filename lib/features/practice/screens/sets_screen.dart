import 'package:flutter/material.dart';
import '../../../core/local_data_service.dart';

class SetsScreen extends StatelessWidget {
  final String subject;
  final String topic;

  SetsScreen({super.key, required this.subject, required this.topic});

  final LocalDataService localDataService = LocalDataService();

  @override
  Widget build(BuildContext context) {
    // --- FORENSIC REPORT LOGIC ---
    final questions = localDataService.getQuestionsForTopicXRay(subject, topic);
    final totalQuestionsFound = questions.length;
    final numberOfSets = (totalQuestionsFound / 10).ceil();
    final sampleQuestion = totalQuestionsFound > 0 ? questions.first.questionText : "N/A";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forensic Report'),
        backgroundColor: Colors.red[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Sets Screen - Internal Data',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const Divider(height: 20),
            
            const Text('1. Inputs Received:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('  - Subject: "$subject"', style: const TextStyle(fontSize: 16, fontFamily: 'monospace')),
            Text('  - Topic: "$topic"', style: const TextStyle(fontSize: 16, fontFamily: 'monospace')),
            const SizedBox(height: 20),

            const Text('2. Database Query Result:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('  - Total Questions Found: $totalQuestionsFound', style: const TextStyle(fontSize: 16, fontFamily: 'monospace')),
            const SizedBox(height: 20),
            
            const Text('3. Calculation:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('  - Number of Sets Calculated: $numberOfSets', style: const TextStyle(fontSize: 16, fontFamily: 'monospace')),
            const SizedBox(height: 20),

            const Text('4. Sample Data:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('  - First Question Found: "$sampleQuestion"', style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
            const SizedBox(height: 30),

            if (totalQuestionsFound == 0)
              Container(
                color: Colors.yellow[200],
                padding: const EdgeInsets.all(12),
                child: const Text(
                  'Diagnosis: The screen is white because ZERO questions were found for this specific Subject/Topic combination. Check for spelling mistakes or extra spaces in your CSV file.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              )
          ],
        ),
      ),
    );
  }
}
