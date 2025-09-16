// lib/features/practice/screens/sets_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/local_data_service.dart';

class SetsScreen extends StatelessWidget {
  final String subject;
  final String topic;

  SetsScreen({super.key, required this.subject, required this.topic});
  
  final LocalDataService localDataService = LocalDataService();

  @override
  Widget build(BuildContext context) {
    final questions = localDataService.getQuestionsForTopic(subject, topic);
    final numberOfSets = (questions.length / 10).ceil();

    return Scaffold(
      backgroundColor: Colors.blueGrey[50], // नया बैकग्राउंड कलर
      appBar: AppBar(
        title: Text(topic),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: numberOfSets,
        itemBuilder: (context, index) {
          final setIndex = index + 1;
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.orange.withOpacity(0.1),
                child: const Icon(Icons.view_list_outlined, color: Colors.orange),
              ),
              title: Text('Set $setIndex', style: const TextStyle(fontWeight: FontWeight.w500)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
              onTap: () {
                context.go(
                  '/practice-mcq',
                  extra: {
                    'subject': subject,
                    'topic': topic,
                    'setIndex': setIndex,
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
