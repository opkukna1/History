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
        // FIX: This part was causing the error. Now it correctly gets
        // and passes all the required data to the ScoreScreen.
        final data = state.extra as Map<String, dynamic>;
        final totalQuestions = data['totalQuestions'] as int;
        final correctAnswers = data['correctAnswers'] as int;
        final subject = data['subject'] as String;
        final topic = data['topic'] as String;
        return ScoreScreen(
          totalQuestions: totalQuestions,
          correctAnswers: correctAnswers,
          subject: subject,
          topic: topic,
        );
      },
    ),
  ],
);
