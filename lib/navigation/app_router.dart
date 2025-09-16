import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/debug/debug_screen.dart'; // Naya import
import '../features/auth/login_screen.dart';
import '../features/home/home_screen.dart';
import '../features/practice/screens/subjects_screen.dart';
import '../features/practice/screens/topics_screen.dart';
import '../features/practice/screens/sets_screen.dart';
import '../features/practice/screens/practice_mcq_screen.dart';
import '../features/practice/screens/score_screen.dart';
import '../features/test_mode/screens/generate_test_screen.dart';
import '../features/test_mode/screens/test_mcq_screen.dart';
import '../features/test_mode/screens/test_score_screen.dart';
import '../features/notes/screens/notes_subjects_screen.dart';
import '../features/notes/screens/notes_list_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/debug', builder: (context, state) => const DebugScreen()), // Naya Rasta
      GoRoute(path: '/subjects', builder: (context, state) => SubjectsScreen(mode: state.extra as String? ?? 'practice')),
      GoRoute(path: '/topics', builder: (context, state) => TopicsScreen(subject: state.extra as Map<String, dynamic>)),
      GoRoute(path: '/sets', builder: (context, state) => SetsScreen(topic: state.extra as Map<String, dynamic>)),
      GoRoute(path: '/practice_mcq', builder: (context, state) => PracticeMcqScreen(set: state.extra as Map<String, dynamic>)),
      GoRoute(path: '/score', builder: (context, state) => ScoreScreen(results: state.extra as Map<String, dynamic>)),
      GoRoute(path: '/generate_test', builder: (context, state) => const GenerateTestScreen()),
      GoRoute(path: '/test_mcq', builder: (context, state) => TestMcqScreen(testSettings: state.extra as Map<String, dynamic>)),
      GoRoute(path: '/test_score', builder: (context, state) => TestScoreScreen(results: state.extra as Map<String, dynamic>)),
      GoRoute(path: '/notes_subjects', builder: (context, state) => const NotesSubjectsScreen()),
      GoRoute(path: '/notes_list', builder: (context, state) => NotesListScreen(subject: state.extra as Map<String, dynamic>)),
    ],
    errorBuilder: (context, state) => Scaffold(body: Center(child: Text('Page not found: ${state.error}'))),
  );
}
