import 'package:flutter/material.dart';

class LogInScreen extends StatelessWidget {
  const LogInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log In'),
        backgroundColor: const Color(0xFF00A862),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome Back',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Logic for signing up the user
                // Example: Navigator.push to go to another screen
                Navigator.pop(
                  context,
                ); // Go back to the welcome screen (for example)
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(
                  0xFF00A862,
                ), // Use backgroundColor instead of primary
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Sign Up', style: TextStyle(fontSize: 18)),
            ),

            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // Navigate to Sign Up screen if user doesn't have an account
                Navigator.pop(
                  context,
                ); // Go back to the Welcome Screen or Sign Up screen
              },
              child: const Text('Don\'t have an account? Sign up'),
            ),
          ],
        ),
      ),
    );
  }
}
