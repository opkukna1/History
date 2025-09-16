// lib/features/practice/screens/score_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScoreScreen extends StatelessWidget {
  final int totalQuestions;
  final int correctAnswers;

  const ScoreScreen({
    super.key,
    required this.totalQuestions,
    required this.correctAnswers,
  });

  @override
  Widget build(BuildContext context) {
    final int wrongAnswers = totalQuestions - correctAnswers;
    final double accuracy = totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8), // Light grey background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Quiz Result',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
              ),
              const SizedBox(height: 30),
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                  child: Column(
                    children: [
                      // मेडल आइकॉन यहाँ से हटा दिया गया है
                      const SizedBox(height: 16),
                      const Text(
                        'Congratulations!',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You have successfully completed the quiz.',
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      // Main Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatCard(
                            context,
                            icon: Icons.check_circle,
                            label: 'Correct',
                            value: correctAnswers.toString(),
                            color: Colors.green,
                          ),
                          _buildStatCard(
                            context,
                            icon: Icons.cancel,
                            label: 'Incorrect',
                            value: wrongAnswers.toString(),
                            color: Colors.red,
                          ),
                           _buildStatCard(
                            context,
                            icon: Icons.percent,
                            label: 'Accuracy',
                            value: '${accuracy.toStringAsFixed(1)}%',
                            color: Colors.blue,
                          ),
                        ],
                      ),
                       const SizedBox(height: 24),
                       // Action Buttons
                       OutlinedButton(
                         onPressed: () {
                           ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Detailed solution coming soon!')),
                          );
                         },
                         style: OutlinedButton.styleFrom(
                           padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                           side: BorderSide(color: Theme.of(context).primaryColor),
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                         ),
                         child: const Text('Detailed Solution', style: TextStyle(fontSize: 16)),
                       ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal, // Your theme color
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Continue'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to build the stat cards
  Widget _buildStatCard(BuildContext context, {required IconData icon, required String label, required String value, required Color color}) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
