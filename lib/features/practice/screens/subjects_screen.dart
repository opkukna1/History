import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/dummy_data.dart';

class SubjectsScreen extends StatelessWidget {
  final String mode;
  const SubjectsScreen({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Subject')),
      body: ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: DummyData.subjects.length,
        itemBuilder: (context, index) {
          final subject = DummyData.subjects[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              title: Text(subject['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () => context.push('/topics', extra: subject),
            ),
          );
        },
      ),
    );
  }
}
