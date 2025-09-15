import 'package:flutter/material.dart';
import '../../../core/dummy_data.dart';

class NotesListScreen extends StatelessWidget {
  final Map<String, dynamic> subject;
  const NotesListScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    // Abhi hum wahi topics use kar rahe hain jo practice mode me the
    final relevantTopics = DummyData.topics
        .where((topic) => topic['subjectId'] == subject['id'])
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('${subject['name']} Notes'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: relevantTopics.length,
        itemBuilder: (context, index) {
          final topic = relevantTopics[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
                    child: Text(
                      topic['name'] as String,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Divider(),
                  // Har topic ke andar dummy PDF notes
                  ListTile(
                    leading: const Icon(Icons.picture_as_pdf_rounded, color: Colors.red),
                    title: const Text('Chapter Notes (Hindi)'),
                    trailing: ElevatedButton(onPressed: () {}, child: const Text('View')),
                  ),
                   ListTile(
                    leading: const Icon(Icons.picture_as_pdf_rounded, color: Colors.red),
                    title: const Text('Chapter Notes (English)'),
                    trailing: ElevatedButton(onPressed: () {}, child: const Text('View')),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
