// lib/navigation/app_router.dart

import 'package:go_router/go_router.dart';
import '../features/home/home_screen.dart';
import '../features/practice/screens/subjects_screen.dart';
import '../features/practice/screens/topics_screen.dart';
import '../features/practice/screens/sets_screen.dart';
import '../features/practice/screens/practice_mcq_screen.dart';

// FIX: Define the router as a top-level variable
final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/subjects',
      // FIX: Provide the required 'mode' parameter. Assuming "Practice" for this route.
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
        // FIX: Pass the data as a single 'set' map, as the screen expects.
        final setData = state.extra as Map<String, dynamic>;
        return PracticeMcqScreen(set: setData);
      },
    ),
  ],
);
