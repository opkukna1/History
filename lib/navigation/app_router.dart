import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// ... other imports
import '../features/test_mode/screens/test_score_screen.dart';
import '../features/notes/screens/notes_subjects_screen.dart'; // Naya import
import '../features/notes/screens/notes_list_screen.dart'; // Naya import

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      // ... Baki ke purane raste ...
      GoRoute(path: '/test_score', builder: (context, state) => TestScoreScreen(results: state.extra as Map<String, dynamic>)),

      // Notes section ke naye raste
      GoRoute(
        path: '/notes_subjects',
        builder: (context, state) => const NotesSubjectsScreen(),
      ),
      GoRoute(
        path: '/notes_list',
        builder: (context, state) {
          final subject = state.extra as Map<String, dynamic>;
          return NotesListScreen(subject: subject);
        },
      ),
    ],
    // ... error builder ...
  );
}
