// lib/features/bookmarks/screens/bookmarks_home_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BookmarksHomeScreen extends StatelessWidget {
  const BookmarksHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: const Text('Bookmarks'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12.0),
        children: [
          Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFFF3E0), // Light orange
                child: Icon(Icons.note_alt_outlined, color: Colors.orange),
              ),
              title: const Text('Bookmarked Notes', style: TextStyle(fontWeight: FontWeight.w500)),
              subtitle: const Text('View bookmarked PDF pages'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
              onTap: () => context.push('/note_bookmarks'),
            ),
          ),
          Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE3F2FD), // Light blue
                child: Icon(Icons.quiz_outlined, color: Colors.blue),
              ),
              title: const Text('Bookmarked Questions', style: TextStyle(fontWeight: FontWeight.w500)),
              subtitle: const Text('View bookmarked MCQs'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
              onTap: () => context.push('/mcq_bookmarks'),
            ),
          ),
        ],
      ),
    );
  }
}
