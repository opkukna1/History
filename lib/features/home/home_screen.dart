// lib/features/home/home_screen.dart

import 'dart:ui'; // BackdropFilter के लिए ज़रूरी

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? lastPressed;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();
        final maxDuration = const Duration(seconds: 2);
        final isWarning = lastPressed == null || now.difference(lastPressed!) > maxDuration;

        if (isWarning) {
          lastPressed = DateTime.now();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Press back again to exit'),
              duration: maxDuration,
            ),
          );
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1.0,
          title: Image.asset(
            'assets/logo.png',
            height: 40,
          ),
          centerTitle: true,
        ),
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
              // bgColor को हटाया क्योंकि ग्लासमोर्फिज्म में इसकी ज़रूरत नहीं
              onTap: () => context.push('/subjects'),
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              context,
              icon: Icons.checklist_rtl_rounded,
              title: 'Test Mode',
              subtitle: 'Generate a real exam experience',
              color: Colors.green,
              // bgColor को हटाया
              onTap: () => context.push('/generate_test'),
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              context,
              icon: Icons.note_alt_outlined,
              title: 'Notes',
              subtitle: 'Read and download PDF notes',
              color: Colors.orange,
              // bgColor को हटाया
              onTap: () => context.push('/notes_subjects'),
            ),
            const SizedBox(height: 24),
            _buildNotices(context),
          ],
        ),
        drawer: const AppDrawer(),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        // FIX: Welcome Card में फिर से हल्का ग्रेडिएंट दिया गया
        gradient: const LinearGradient(
          colors: [Color(0xFFEDE7F6), Color(0xFFF3E5F5)], // Light purple gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome Back!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple.shade900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ready to conquer your exams today?',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.deepPurple.shade700,
            ),
          ),
        ],
      ),
    );
  }

  // FIX: Action Card में ग्लासमोर्फिज्म इफ़ेक्ट जोड़ा गया
  Widget _buildActionCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    return ClipRRect( // कोने गोल करने के लिए
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter( // बैकग्राउंड को धुंधला करने के लिए
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // धुंधलापन एडजस्ट करें
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3), // हल्का पारदर्शी सफेद रंग
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)), // हल्का बॉर्डर
          ),
          child: Material( // InkWell के लिए ज़रूरी
            color: Colors.transparent, // ताकि InkWell का रंग दिखे
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(radius: 28, backgroundColor: color.withOpacity(0.2), child: Icon(icon, color: color, size: 32)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87), // टेक्स्ट का कलर काला किया
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54), // टेक्स्ट का कलर काला किया
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, color: Colors.black45, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildNotices(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Important Notices',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800, 
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: const ListTile(
            leading: Icon(Icons.campaign_rounded, color: Colors.deepPurple, size: 30),
            title: Text('RPSC Exam Date Announced!', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
            subtitle: Text('The exam will be held on 25th Oct. All the best!', style: TextStyle(fontSize: 14)),
          ),
        ),
      ],
    );
  }
}

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
          ListTile(leading: const Icon(Icons.home_outlined), title: const Text('Home'), onTap: () => context.go('/')),
          ListTile(leading: const Icon(Icons.chrome_reader_mode_outlined), title: const Text('Practice Mode'), onTap: () => context.push('/subjects')),
          ListTile(leading: const Icon(Icons.checklist_rtl_rounded), title: const Text('Test Mode'), onTap: () => context.push('/generate_test')),
          ListTile(leading: const Icon(Icons.note_alt_outlined), title: const Text('Notes'), onTap: () => context.push('/notes_subjects')),
          const Divider(),
          ListTile(leading: const Icon(Icons.logout_outlined), title: const Text('Logout'), onTap: () {
            context.go('/');
          }),
        ],
      ),
    );
  }
}
