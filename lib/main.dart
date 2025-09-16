// lib/main.dart

import 'package:flutter/material.dart';
import 'package:history_metallum/navigation/app_router.dart'; // Correct import

void main() {
  runApp(const HistoryMetallumApp());
}

class HistoryMetallumApp extends StatelessWidget {
  const HistoryMetallumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'History App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // FIX: Call the router variable directly, not through a class.
      routerConfig: router, 
    );
  }
}
