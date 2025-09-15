import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/local_data_service.dart'; // Ab hum local data service use karenge

class NotesSubjectsScreen extends StatelessWidget {
  const NotesSubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Data ab local service se aayega
    final subjects = localDataService.getSubjects();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Subject for Notes'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final subject = subjects[index];
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
