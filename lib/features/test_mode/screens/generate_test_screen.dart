import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GenerateTestScreen extends StatefulWidget {
  const GenerateTestScreen({super.key});

  @override
  State<GenerateTestScreen> createState() => _GenerateTestScreenState();
}

class _GenerateTestScreenState extends State<GenerateTestScreen> {
  String _selectedSubject = 'History';
  String _selectedTopic = 'Indus Valley Civilization';
  double _difficulty = 5;
  double _questionCount = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Custom Test'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Subject Dropdown
          _buildDropdown('Subject', ['History', 'Geography'], _selectedSubject, (val) {
            setState(() => _selectedSubject = val!);
          }),
          const SizedBox(height: 16),
          // Topic Dropdown
          _buildDropdown('Topic', ['Indus Valley Civilization', 'Vedic Period'], _selectedTopic, (val) {
             setState(() => _selectedTopic = val!);
          }),
          const SizedBox(height: 24),
          // Difficulty Slider
          _buildSlider('Difficulty', _difficulty, 1, 10, (val) {
            setState(() => _difficulty = val);
          }),
          const SizedBox(height: 16),
           // Question Count Slider
          _buildSlider('Number of Questions', _questionCount, 5, 50, (val) {
             setState(() => _questionCount = val);
          }),
          const SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Yh button ab kaam karega
            onPressed: () {
              final testSettings = {
                'subject': _selectedSubject,
                'topic': _selectedTopic,
                'difficulty': _difficulty.toInt(),
                'count': _questionCount.toInt(),
              };
              context.push('/test_mcq', extra: testSettings);
            },
            child: const Text('Start Test'),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String value, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toInt()}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          label: value.toInt().toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
