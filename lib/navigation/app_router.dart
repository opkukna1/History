import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// ... other imports
import '../features/test_mode/screens/generate_test_screen.dart';
import '../features/test_mode/screens/test_mcq_screen.dart'; // Naya import
import '../features/test_mode/screens/test_score_screen.dart'; // Naya import

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      
      // ... Practice Mode routes ...
      
      // Test Mode ke naye raste
      GoRoute(
        path: '/generate_test',
        builder: (context, state) => const GenerateTestScreen(),
      ),
       GoRoute(
        path: '/test_mcq',
        builder: (context, state) {
          final settings = state.extra as Map<String, dynamic>;
          return TestMcqScreen(testSettings: settings);
        },
      ),
       GoRoute(
        path: '/test_score',
        builder: (context, state) {
          final results = state.extra as Map<String, dynamic>;
          return TestScoreScreen(results: results);
        },
      ),
    ],
    // ... error builder ...
  );
}
