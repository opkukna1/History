import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/dummy_data.dart';

class NotesSubjectsScreen extends StatelessWidget {
  const NotesSubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Subject for Notes'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: DummyData.subjects.length,
        itemBuilder: (context, index) {
          final subject = DummyData.subjects[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: const Icon(Icons.topic_outlined),
              title: Text(subject['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () => context.push('/notes_list', extra: subject),
            ),
          );
        },
      ),
    );
  }
}
