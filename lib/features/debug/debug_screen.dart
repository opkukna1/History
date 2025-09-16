import 'package:flutter/material.dart';
import '../../core/local_data_service.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  late Future<void> _loadingFuture;

  @override
  void initState() {
    super.initState();
    _loadingFuture = localDataService.loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CSV X-Ray Report 🕵️‍♂️')),
      body: FutureBuilder<void>(
        future: _loadingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final headers = localDataService.getDetectedHeaders();
          final samples = localDataService.getSampleQuestions(2);

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text('Total Questions Loaded: ${localDataService.getLoadedQuestionCount()}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(height: 30),
              const Text('Headers Found in CSV:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(headers.toString(), style: const TextStyle(fontFamily: 'monospace')),
                ),
              ),
              const Divider(height: 30),
              const Text('Sample Data (First 2 Questions):', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if (samples.isNotEmpty)
                ...samples.map((sample) => Card(
                      margin: const EdgeInsets.only(top: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: sample.entries.map((e) => Text("'${e.key}': '${e.value}'", style: const TextStyle(fontFamily: 'monospace'))).toList(),
                        ),
                      ),
                    )),
            ],
          );
        },
      ),
    );
  }
}
