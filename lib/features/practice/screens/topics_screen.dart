import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/local_data_service.dart';

class TopicsScreen extends StatelessWidget {
  final String subject;
  const TopicsScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    // डेटा मैनेजर का कनेक्शन जोड़ें
    final LocalDataService localDataService = LocalDataService();
    final topics = localDataService.getTopicsForSubject(subject);

    return Scaffold(
      appBar: AppBar(
        title: Text(subject),
      ),
      body: ListView.builder(
        itemCount: topics.length,
        itemBuilder: (context, index) {
          final topicName = topics[index];
          return Card(
            child: ListTile(
              title: Text(topicName),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // SetsScreen पर subject और topic दोनों भेजें
                context.go(
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
