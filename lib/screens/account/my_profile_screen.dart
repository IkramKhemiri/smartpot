import 'package:flutter/material.dart';
import 'package:smartpot/widgets/custom_bottom_navbar.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const green700 = Color(0xFF047857);
    const gray200 = Color(0xFFE5E7EB);
    const gray300 = Color(0xFFD1D5DB);
    const gray500 = Color(0xFF6B7280);
    const white = Colors.white;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          'Account',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Image.asset(
            'assets/images/logoApp1.png',
            width: 24,
            height: 24,
            fit: BoxFit.contain,
            semanticLabel: 'App logo',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onPressed: () {},
            tooltip: 'More options',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Section
            const CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage('assets/images/profile.jpg'),
            ),
            const SizedBox(height: 10),
            const Text(
              'Username',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Email: user@example.com',
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            // Banner
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(color: gray300),
                color: gray200,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: green700,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Account Overview',
                        style: TextStyle(
                          color: white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Account Settings Card
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.settings, color: green700, size: 40),
                title: const Text(
                  'Account Settings',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Manage your account settings'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigate to account settings
                },
              ),
            ),
            const SizedBox(height: 20),
            // Log Out Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Handle logout
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: green700,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Log Out',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 3, // Account tab
        selectedColor: green700,
        unselectedColor: gray500,
        selectedFontSize: 12,
        unselectedFontSize: 10,
      ),
    );
  }
}
