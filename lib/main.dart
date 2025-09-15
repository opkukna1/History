import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:async';

// Main App Entry Point
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const HistoryMetallumApp(),
    ),
  );
}

// Simple State Management using Provider
class AppState extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  void login() {
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }
}

// App Router for Navigation using GoRouter
final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'home',
          builder: (BuildContext context, GoRouterState state) {
            return const HomeScreen();
          },
        ),
        GoRoute(
          path: 'add_question',
          builder: (BuildContext context, GoRouterState state) {
            return const AddQuestionScreen();
          },
        ),
        GoRoute(
          path: 'generate_test',
          builder: (BuildContext context, GoRouterState state) {
            return const GenerateTestScreen();
          },
        ),
        GoRoute(
          path: 'notes',
          builder: (BuildContext context, GoRouterState state) {
            return const NotesScreen();
          },
        ),
        GoRoute(
          path: 'reading_mode',
          builder: (BuildContext context, GoRouterState state) {
            return const ReadingModeScreen();
          },
        ),
        GoRoute(
          path: 'question_list',
          builder: (BuildContext context, GoRouterState state) {
            final subject = state.extra as String?;
            return QuestionListScreen(subject: subject ?? 'Unknown');
          },
        ),
      ],
    ),
  ],
);

// Main App Widget
class HistoryMetallumApp extends StatelessWidget {
  const HistoryMetallumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'History Metallum',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple, brightness: Brightness.dark),
      ),
      themeMode: ThemeMode.system,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

// --- Screens ---

// Login Screen
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Icon(
                  Icons.school_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 20),
                Text(
                  'History Metallum',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headlineLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Your Gateway to Exam Success',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 40),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Login', style: TextStyle(fontSize: 16)),
                  onPressed: () {
                    Provider.of<AppState>(context, listen: false).login();
                    context.go('/home');
                  },
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  icon: const Icon(Icons.login), 
                  label: const Text('Sign in with Google'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                     Provider.of<AppState>(context, listen: false).login();
                     context.go('/home');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Home Screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      drawer: AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildWelcomeCard(context),
          const SizedBox(height: 16),
          _buildActionCard(
            context,
            icon: Icons.note_add_rounded,
            title: 'Generate Test',
            subtitle: 'Create a custom test based on your needs.',
            onTap: () => context.go('/generate_test'),
          ),
          const SizedBox(height: 16),
           _buildActionCard(
            context,
            icon: Icons.chrome_reader_mode_rounded,
            title: 'Reading Mode',
            subtitle: 'Read questions and answers by topic.',
            onTap: () => context.go('/reading_mode'),
          ),
          const SizedBox(height: 16),
          _buildActionCard(
            context,
            icon: Icons.book_rounded,
            title: 'Study Notes',
            subtitle: 'Access and download PDF notes.',
            onTap: () => context.go('/notes'),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: const Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('How is your study going today?'),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon,
                  size: 40, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// App Drawer (Side Menu)
class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.deepPurple,
            ),
            child: Text(
              'History Metallum',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              context.go('/home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_circle),
            title: const Text('Add Question'),
            onTap: () {
              context.go('/add_question');
            },
          ),
          ListTile(
            leading: const Icon(Icons.note_add),
            title: const Text('Generate Test'),
            onTap: () {
               context.go('/generate_test');
            },
          ),
           ListTile(
            leading: const Icon(Icons.chrome_reader_mode),
            title: const Text('Reading Mode'),
            onTap: () {
              context.go('/reading_mode');
            },
          ),
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('Notes'),
            onTap: () {
              context.go('/notes');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Provider.of<AppState>(context, listen: false).logout();
              context.go('/');
            },
          ),
        ],
      ),
    );
  }
}

// Add Question Screen
class AddQuestionScreen extends StatelessWidget {
  const AddQuestionScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add a New Question')),
      body: const Center(child: Text('Add Question Form will be here.')),
    );
  }
}

// Generate Test Screen
class GenerateTestScreen extends StatelessWidget {
  const GenerateTestScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generate a Test')),
      body: const Center(child: Text('Test Generation Options will be here.')),
    );
  }
}

// Notes Screen
class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Study Notes')),
      body: const Center(child: Text('PDF Notes list will be here.')),
    );
  }
}

// Reading Mode Screen
class ReadingModeScreen extends StatelessWidget {
  const ReadingModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample subjects
    final subjects = ['History', 'Geography', 'Art & Culture', 'Polity'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Mode - Select Subject'),
      ),
      body: ListView.builder(
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final subject = subjects[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(subject, style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
              onTap: () {
                context.go('/question_list', extra: subject);
              },
            ),
          );
        },
      ),
    );
  }
}


// Question List Screen (for Reading Mode)
class QuestionListScreen extends StatefulWidget {
  final String subject;
  const QuestionListScreen({super.key, required this.subject});

  @override
  State<QuestionListScreen> createState() => _QuestionListScreenState();
}

class _QuestionListScreenState extends State<QuestionListScreen> {
  // Sample data
  final Map<String, List<Map<String, String>>> questions = {
    'History': [
      {
        'q': 'Who was the first President of India?',
        'a': 'Dr. Rajendra Prasad'
      },
      {'q': 'When did India get independence?', 'a': '15th August 1947'},
    ],
    'Geography': [
      {'q': 'Which is the longest river in India?', 'a': 'The Ganges'},
      {'q': 'What is the capital of Rajasthan?', 'a': 'Jaipur'},
    ]
  };

  int? _expandedQuestionIndex;

  @override
  Widget build(BuildContext context) {
    final subjectQuestions = questions[widget.subject] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject),
      ),
      body: subjectQuestions.isEmpty
          ? const Center(child: Text('No questions available for this subject yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: subjectQuestions.length,
              itemBuilder: (context, index) {
                final item = subjectQuestions[index];
                final isExpanded = _expandedQuestionIndex == index;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Q: ${item['q']}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        if (isExpanded)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Ans: ${item['a']}',
                              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                            ),
                          )
                        else
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _expandedQuestionIndex = index;
                                });
                              },
                              child: const Text('Show Answer'),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
