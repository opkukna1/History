import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/login_screen.dart';
import '../features/home/home_screen.dart';
import '../features/practice/screens/subjects_screen.dart';
import '../features/practice/screens/topics_screen.dart';
import '../features/practice/screens/sets_screen.dart';
import '../features/practice/screens/practice_mcq_screen.dart';
import '../features/practice/screens/score_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/subjects',
        builder: (context, state) => const SubjectsScreen(mode: 'practice'),
      ),
       GoRoute(
        path: '/topics',
        builder: (context, state) {
          final subject = state.extra as Map<String, dynamic>;
          return TopicsScreen(subject: subject);
        }
      ),
      GoRoute(
        path: '/sets',
        builder: (context, state) {
           final topic = state.extra as Map<String, dynamic>;
          return SetsScreen(topic: topic);
        }
      ),
       GoRoute(
        path: '/practice_mcq',
        builder: (context, state) {
           final set = state.extra as Map<String, dynamic>;
          return PracticeMcqScreen(set: set);
        }
      ),
      GoRoute(
        path: '/score',
        builder: (context, state) {
           final results = state.extra as Map<String, dynamic>;
          return ScoreScreen(results: results);
        }
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: ${state.error}'),
      ),
    ),
  );
}
