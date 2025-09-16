// lib/features/practice/screens/subjects_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/local_data_service.dart';

class SubjectsScreen extends StatefulWidget {
  final String mode;
  const SubjectsScreen({super.key, required this.mode});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  final LocalDataService localDataService = LocalDataService();
  late Future<void> _loadingFuture;

  @override
  void initState() {
    super.initState();
    _loadingFuture = localDataService.loadQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50], // नया बैकग्राउंड कलर
      appBar: AppBar(
        title: Text('${widget.mode} Mode - Subjects'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: FutureBuilder<void>(
        future: _loadingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final subjects = localDataService.getSubjects();
          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final subjectName = subjects[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    child: const Icon(Icons.menu_book, color: Colors.blue),
                  ),
                  title: Text(subjectName, style: const TextStyle(fontWeight: FontWeight.w500)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                  onTap: () => context.go('/topics', extra: subjectName),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
