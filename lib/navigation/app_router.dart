// lib/navigation/app_router.dart

import 'package:go_router/go_router.dart';
import '../features/home/home_screen.dart';
import '../features/practice/screens/subjects_screen.dart';
import '../features/practice/screens/topics_screen.dart';
import '../features/practice/screens/sets_screen.dart';
import '../features/practice/screens/practice_mcq_screen.dart';
import '../features/practice/screens/score_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/subjects',
      builder: (context, state) => const SubjectsScreen(mode: "Practice"),
    ),
    GoRoute(
      path: '/topics',
      builder: (context, state) {
        final subject = state.extra as String;
        return TopicsScreen(subject: subject);
      },
    ),
    GoRoute(
      path: '/sets',
      builder: (context, state) {
        final data = state.extra as Map<String, String>;
        final subject = data['subject']!;
        final topic = data['topic']!;
        return SetsScreen(subject: subject, topic: topic);
      },
    ),
     GoRoute(
      path: '/practice-mcq',
      builder: (context, state) {
        final setData = state.extra as Map<String, dynamic>;
        return PracticeMcqScreen(set: setData);
      },
    ),
    GoRoute(
      path: '/score',
      builder: (context, state) {
        // यहाँ डेटा Integer के रूप में आ रहा है, इसलिए Map<String, int>
        final data = state.extra as Map<String, int>;
        final totalQuestions = data['totalQuestions']!;
        final correctAnswers = data['correctAnswers']!;
        return ScoreScreen(
          totalQuestions: totalQuestions,
          correctAnswers: correctAnswers,
        );
      },
    ),
  ],
);
