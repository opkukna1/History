import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/local_data_service.dart';

// Ek global instance banayenge taki data baar baar load na ho
final localDataService = LocalDataService();

class SetsScreen extends StatelessWidget {
  final Map<String, dynamic> topic;
  const SetsScreen({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    // Ab sets yahan se aayenge
    final relevantSets = localDataService.getSetsForTopic(topic['name'] as String);

    return Scaffold(
      appBar: AppBar(title: Text(topic['name'] as String)),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: relevantSets.length,
        itemBuilder: (context, index) {
          final set = relevantSets[index];
          return Card(
            child: InkWell(
              onTap: () => context.push('/practice_mcq', extra: set),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text(
                      set['name'] as String,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  const SizedBox(height: 8),
                  Text('${set['questionCount']} Questions', style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
