// lib/features/practice/screens/topics_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/local_data_service.dart';

class TopicsScreen extends StatelessWidget {
  final String subject;
  const TopicsScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    final LocalDataService localDataService = LocalDataService();
    final topics = localDataService.getTopicsForSubject(subject);

    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: Text(subject),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: topics.length,
        itemBuilder: (context, index) {
          final topicName = topics[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green.withOpacity(0.1),
                child: const Icon(Icons.topic_outlined, color: Colors.green),
              ),
              title: Text(topicName, style: const TextStyle(fontWeight: FontWeight.w500)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
              onTap: () {
                // FIX: Using .push() to maintain navigation history
                context.push(
                  '/sets',
                  extra: {'subject': subject, 'topic': topicName},
                );
              },
            ),
          );
        },
      ),
    );
  }
}
