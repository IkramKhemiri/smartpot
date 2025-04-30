import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final greenColor = const Color(
      0xFF16A34A,
    ); // Utiliser une couleur personnalisée

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: greenColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Example of a Dashboard Widget
            const Text(
              'Welcome to Your Dashboard',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            // Example Card for Plant Stats
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(Icons.grass, color: greenColor, size: 40),
                title: const Text(
                  'Your Plant Statistics',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('See how many plants you have and more!'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigate to a detailed statistics screen
                },
              ),
            ),
            const SizedBox(height: 20),
            // Explore Plants Section or other widgets
            const Text(
              'Explore More',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            // Add buttons, cards, or widgets to explore plants, articles, etc.
            ElevatedButton(
              onPressed: () {
                // Handle navigation to explore plants
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: greenColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Explore Plants'),
            ),
          ],
        ),
      ),
    );
  }
}
