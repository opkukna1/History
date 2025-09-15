import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/dummy_data.dart';

class TopicsScreen extends StatelessWidget {
  final Map<String, dynamic> subject;
  const TopicsScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    final relevantTopics = DummyData.topics
        .where((topic) => topic['subjectId'] == subject['id'])
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(subject['name'] as String)),
      body: ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: relevantTopics.length,
        itemBuilder: (context, index) {
          final topic = relevantTopics[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              title: Text(topic['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () => context.push('/sets', extra: topic),
            ),
          );
        },
      ),
    );
  }
}
