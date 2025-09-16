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
      appBar: AppBar(
        title: Text('${widget.mode} Mode - Subjects'),
      ),
      body: FutureBuilder<void>(
        future: _loadingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // This was the line with the copy-paste error. This is the correct version.
          final subjects = localDataService.getSubjects();
          return ListView.builder(
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final subjectName = subjects[index];
              return Card(
                child: ListTile(
                  title: Text(subjectName),
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
