import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/local_data_service.dart';

class SetsScreen extends StatelessWidget {
  final String subject;
  final String topic;

  SetsScreen({super.key, required this.subject, required this.topic});
  
  // डेटा मैनेजर का कनेक्शन जोड़ें
  final LocalDataService localDataService = LocalDataService();

  @override
  Widget build(BuildContext context) {
    final questions = localDataService.getQuestionsForTopic(subject, topic);
    final numberOfSets = (questions.length / 10).ceil();

    return Scaffold(
      appBar: AppBar(
        title: Text(topic),
      ),
      body: ListView.builder(
        itemCount: numberOfSets,
        itemBuilder: (context, index) {
          final setIndex = index + 1;
          return Card(
            child: ListTile(
              title: Text('Set $setIndex'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                context.go(
                  '/practice-mcq',
                  extra: {
                    'subject': subject,
                    'topic': topic,
                    'setIndex': setIndex,
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
