import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ScoreScreen extends StatelessWidget {
  final Map<String, dynamic> results;
  const ScoreScreen({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    final int score = results['score'] as int;
    final int total = results['total'] as int;
    final double percentage = total > 0 ? (score / total) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Result'),
        automaticallyImplyLeading: false, // Hides the back button
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularPercentIndicator(
                radius: 80.0,
                lineWidth: 15.0,
                percent: percentage,
                center: Text(
                  "${(percentage * 100).toStringAsFixed(1)}%",
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                progressColor: Colors.green,
                backgroundColor: Colors.grey.shade300,
                circularStrokeCap: CircularStrokeCap.round,
              ),
              const SizedBox(height: 32),
              Text(
                'You scored $score out of $total',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  // TODO: Implement Check Answers functionality
                },
                child: const Text('Check Answers'),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  // Go back 3 pages: Score -> MCQ -> Sets
                  context.pop();
                  context.pop();
                  context.pop();
                },
                child: const Text('Back to Subjects'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
