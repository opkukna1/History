import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../app_state.dart'; // YAH HAI WOH NAYI LINE JO ERROR THEEK KAREGI

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.school_rounded, size: 80, color: Colors.deepPurple),
              const SizedBox(height: 20),
              const Text('History Metallum', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  Provider.of<AppState>(context, listen: false).login();
                  context.go('/home');
                },
                child: const Text('Enter App'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
