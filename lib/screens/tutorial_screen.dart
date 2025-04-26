import 'package:flutter/material.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('How to Use Plantify')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: const [
            Text(
              '1. Add your plants 🌱',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('Tap on the "+" icon to add a new plant with care preferences.'),
            SizedBox(height: 20),
            Text(
              '2. Monitor your garden 📊',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('Get a quick view of plant needs: watering, sunlight, and more.'),
            SizedBox(height: 20),
            Text(
              '3. Set reminders ⏰',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('Turn on notifications so you never forget to water again.'),
          ],
        ),
      ),
    );
  }
}
