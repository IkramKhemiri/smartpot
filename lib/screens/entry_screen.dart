import 'package:flutter/material.dart';
import 'welcome_screen.dart';

class EntryScreen extends StatelessWidget {
  const EntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const plantBudTextStyle = TextStyle(
      fontFamily: 'FredokaOne',
      fontSize: 32,
      color: Color(0xFF1B3A1A),
      fontWeight: FontWeight.w400,
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFDF6), Color(0xFFF7EFE5)],
          ),
        ),
        child: Center(
          child: SizedBox(
            width: 288,
            height: 500,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 64),
                const Text(
                  'Welcome to',
                  style: TextStyle(
                    color: Color(0xFF1B3A1A),
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('PlantBud', style: plantBudTextStyle),
                const SizedBox(height: 40),
                Semantics(
                  label: 'Illustration of a green seedling in a hand',
                  child: Image.network(
                    'https://storage.googleapis.com/a1aa/image/380fe39b-8cd2-4324-6be4-706e81554c3d.jpg',
                    width: 160,
                    height: 160,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 56),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B3A1A),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  child: const Text('Enter My Garden'),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Start Planting',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
