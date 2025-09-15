import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/dummy_data.dart';

class SetsScreen extends StatelessWidget {
  final Map<String, dynamic> topic;
  const SetsScreen({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    final relevantSets =
        DummyData.sets.where((set) => set['topicId'] == topic['id']).toList();

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
          final isLocked = (set['name'] as String).contains('Locked');

          return Card(
            color: isLocked ? Colors.grey.shade200 : Theme.of(context).cardColor,
            child: InkWell(
              onTap: isLocked ? null : () => context.push('/practice_mcq', extra: set),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLocked)
                    Icon(Icons.lock_rounded, color: Colors.grey.shade600, size: 32)
                  else
                    Text(
                      set['name'] as String,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  const SizedBox(height: 8),
                  Text(isLocked ? 'Coming Soon' : '3 Questions', style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
