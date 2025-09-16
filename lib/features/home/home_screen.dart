// lib/features/home/home_screen.dart

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
        // FIX: AppBar में Dashboard की जगह लोगो जोड़ा गया
        appBar: AppBar(
          backgroundColor: Colors.transparent, // AppBar को पारदर्शी बनाएं
          elevation: 0, // शैडो हटा दें
          title: Image.asset(
            'assets/logo.png', // अपनी लोगो इमेज का पाथ यहाँ डालें
            height: 40, // लोगो की ऊँचाई एडजस्ट करें
          ),
          centerTitle: true, // लोगो को बीच में रखें
          iconTheme: const IconThemeData(color: Colors.white), // Drawer आइकॉन का कलर
        ),
        // FIX: होम स्क्रीन के बैकग्राउंड में ग्रेडिएंट जोड़ा गया
        extendBodyBehindAppBar: true, // ऐप बार के पीछे ग्रेडिएंट फैलाएं
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF6A1B9A), // गहरा बैंगनी
                Color(0xFF9C27B0), // हल्का बैंगनी
                Color(0xFFE040FB), // चमकीला गुलाबी-बैंगनी
              ],
              stops: [0.1, 0.5, 0.9],
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.only(top: kToolbarHeight + 40, left: 16, right: 16), // AppBar के नीचे से पैडिंग
            children: [
              _buildWelcomeCard(context),
              const SizedBox(height: 24),
              _buildActionCard(
                context,
                icon: Icons.chrome_reader_mode_outlined,
                title: 'Practice Mode',
                subtitle: 'Learn topic-wise with sets',
                color: Colors.blue,
                bgColor: Colors.blue.shade50, // FIX: हल्का बैकग्राउंड कलर
                onTap: () => context.push('/subjects'),
              ),
              const SizedBox(height: 16),
              _buildActionCard(
                context,
                icon: Icons.checklist_rtl_rounded,
                title: 'Test Mode',
                subtitle: 'Generate a real exam experience',
                color: Colors.green,
                bgColor: Colors.green.shade50, // FIX: हल्का बैकग्राउंड कलर
                onTap: () => context.push('/generate_test'),
              ),
              const SizedBox(height: 16),
              _buildActionCard(
                context,
                icon: Icons.note_alt_outlined,
                title: 'Notes',
                subtitle: 'Read and download PDF notes',
                color: Colors.orange,
                bgColor: Colors.orange.shade50, // FIX: हल्का बैकग्राउंड कलर
                onTap: () => context.push('/notes_subjects'),
              ),
              const SizedBox(height: 24),
              _buildNotices(context),
            ],
          ),
        ),
        drawer: const AppDrawer(),
      ),
    );
  }

  // FIX: Welcome Card को और आकर्षक बनाया गया
  Widget _buildWelcomeCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        // FIX: Welcome Card में ग्रेडिएंट बैकग्राउंड
        gradient: const LinearGradient(
          colors: [Color(0xFFB39DDB), Color(0xFFE1BEE7)], // हल्के बैंगनी रंग
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
              color: Colors.deepPurple.shade900, // गहरा टेक्स्ट कलर
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ready to conquer your exams today?',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.deepPurple.shade700, // गहरा टेक्स्ट कलर
            ),
          ),
        ],
      ),
    );
  }

  // FIX: Action Card में नया bgColor पैरामीटर जोड़ा गया
  Widget _buildActionCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required Color color, Color? bgColor, required VoidCallback onTap}) {
    return Card(
      elevation: 4, // शैडो बढ़ाई गई
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: bgColor ?? Colors.white, // FIX: बैकग्राउंड कलर का उपयोग
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(radius: 28, backgroundColor: color.withOpacity(0.2), child: Icon(icon, color: color, size: 32)), // आइकॉन का साइज बढ़ाया गया
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade400, size: 20),
            ],
          ),
        ),
      ),
    );
  }
  
  // FIX: Notices कार्ड का डिज़ाइन भी बेहतर किया गया
  Widget _buildNotices(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Important Notices',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white, // टेक्स्ट का कलर सफेद किया गया
            shadows: const [
              Shadow(
                blurRadius: 4.0,
                color: Colors.black38,
                offset: Offset(1.0, 1.0),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 4, // शैडो बढ़ाई गई
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
          ListTile(leading: const Icon(Icons.home_outlined), title: const Text('Home'), onTap: () => context.go('/')), // FIX: /home की जगह /
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
