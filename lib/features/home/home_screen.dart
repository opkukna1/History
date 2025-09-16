// lib/features/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// NOTE: Make sure you have these files in your project if you use them
// import '../../app_state.dart'; 
// import 'package:provider/provider.dart';

// HomeScreen को StatefulWidget में बदला गया
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // आखिरी बार बैक बटन कब दबाया गया, यह स्टोर करने के लिए वेरिएबल
  DateTime? lastPressed;

  @override
  Widget build(BuildContext context) {
    // WillPopScope विजेट जोड़ा गया ताकि बैक बटन को कंट्रोल कर सकें
    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();
        final maxDuration = const Duration(seconds: 2);
        final isWarning = lastPressed == null || now.difference(lastPressed!) > maxDuration;

        if (isWarning) {
          lastPressed = DateTime.now();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Press back again to exit'),
              duration: maxDuration,
            ),
          );
          return false; // ऐप को बंद होने से रोकता है
        } else {
          return true; // ऐप को बंद होने देता है
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Dashboard')),
        drawer: const AppDrawer(),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildWelcomeCard(context),
            const SizedBox(height: 24),
            _buildActionCard(
              context,
              icon: Icons.chrome_reader_mode_outlined,
              title: 'Practice Mode',
              subtitle: 'Learn topic-wise with sets',
              color: Colors.blue,
              onTap: () => context.push('/subjects'),
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              context,
              icon: Icons.checklist_rtl_rounded,
              title: 'Test Mode',
              subtitle: 'Generate a real exam experience',
              color: Colors.green,
              onTap: () => context.push('/generate_test'),
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              context,
              icon: Icons.note_alt_outlined,
              title: 'Notes',
              subtitle: 'Read and download PDF notes',
              color: Colors.orange,
              onTap: () => context.push('/notes_subjects'),
            ),
            const SizedBox(height: 24),
            _buildNotices(context),
          ],
        ),
      ),
    );
  }

  // बाकी के विजेट्स वैसे ही रहेंगे
  Widget _buildWelcomeCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome Back!', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onPrimaryContainer)),
          const SizedBox(height: 8),
          Text('Ready to conquer your exams today?', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8))),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(radius: 24, backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color, size: 28)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildNotices(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Important Notices', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
          child: const ListTile(
            leading: Icon(Icons.campaign_rounded, color: Colors.deepPurple),
            title: Text('RPSC Exam Date Announced!', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('The exam will be held on 25th Oct. All the best!'),
          ),
        ),
      ],
    );
  }
}

// AppDrawer जैसा था वैसा ही रहेगा
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.deepPurple),
            child: Text('History Metallum', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(leading: const Icon(Icons.home_outlined), title: const Text('Home'), onTap: () => context.go('/home')),
          ListTile(leading: const Icon(Icons.chrome_reader_mode_outlined), title: const Text('Practice Mode'), onTap: () => context.push('/subjects')),
          ListTile(leading: const Icon(Icons.checklist_rtl_rounded), title: const Text('Test Mode'), onTap: () => context.push('/generate_test')),
          ListTile(leading: const Icon(Icons.note_alt_outlined), title: const Text('Notes'), onTap: () => context.push('/notes_subjects')),
          const Divider(),
          ListTile(leading: const Icon(Icons.logout_outlined), title: const Text('Logout'), onTap: () {
            // Provider.of<AppState>(context, listen: false).logout();
            context.go('/');
          }),
        ],
      ),
    );
  }
}
