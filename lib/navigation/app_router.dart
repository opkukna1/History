import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/home/home_screen.dart';
import '../features/practice/screens/subjects_screen.dart';
import '../features/practice/screens/topics_screen.dart';
import '../features/practice/screens/sets_screen.dart';
import '../features/practice/screens/practice_mcq_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/subjects',
      builder: (context, state) => const SubjectsScreen(),
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
        // यहाँ डेटा को सही तरीके से निकालें
        final data = state.extra as Map<String, String>;
        final subject = data['subject']!;
        final topic = data['topic']!;
        return SetsScreen(subject: subject, topic: topic);
      },
    ),
     GoRoute(
      path: '/practice-mcq',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        final subject = data['subject'] as String;
        final topic = data['topic'] as String;
        final setIndex = data['setIndex'] as int;
        return PracticeMcqScreen(subject: subject, topic: topic, setIndex: setIndex);
      },
    ),
  ],
);
