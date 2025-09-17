// lib/navigation/app_router.dart

import 'package:go_router/go_router.dart';
import '../features/home/home_screen.dart';
import '../features/practice/screens/subjects_screen.dart';
import '../features/practice/screens/topics_screen.dart';
import '../features/practice/screens/sets_screen.dart';
import '../features/practice/screens/practice_mcq_screen.dart';
import '../features/practice/screens/score_screen.dart';
import '../features/notes/screens/notes_subjects_screen.dart';
import '../features/notes/screens/notes_topics_screen.dart';
import '../features/notes/screens/note_viewer_screen.dart';
// FIX: नई बुकमार्क स्क्रीन इम्पोर्ट करें
import '../features/bookmarks/screens/bookmarks_home_screen.dart';
import '../features/bookmarks/screens/note_bookmarks_screen.dart';
import '../features/bookmarks/screens/mcq_bookmarks_screen.dart';


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
    GoRoute(
      path: '/notes_subjects',
      builder: (context, state) => const NotesSubjectsScreen(),
    ),
    GoRoute(
      path: '/notes_topics',
      builder: (context, state) {
        final subjectData = state.extra as Map<String, dynamic>;
        return NotesTopicsScreen(subjectData: subjectData);
      },
    ),
    GoRoute(
      path: '/note_viewer',
      builder: (context, state) {
        final topicData = state.extra as Map<String, dynamic>;
        final int? initialPage = topicData.containsKey('initialPage') ? topicData['initialPage'] as int : null;
        return NoteViewerScreen(topicData: topicData, initialPage: initialPage);
      },
    ),
    
    // FIX: बुकमार्क्स के लिए नए Routes
    GoRoute(
      path: '/bookmarks_home',
      builder: (context, state) => const BookmarksHomeScreen(),
    ),
    GoRoute(
      path: '/note_bookmarks',
      builder: (context, state) => const NoteBookmarksScreen(),
    ),
    GoRoute(
      path: '/mcq_bookmarks',
      builder: (context, state) => const McqBookmarksScreen(),
    ),
  ],
);
