import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.palette),
            title: Text('Theme'),
            subtitle: Text('Light / Dark Mode'),
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notifications'),
            subtitle: Text('Watering reminders'),
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About Plantify'),
            subtitle: Text('Version 1.0.0'),
          ),
        ],
      ),
    );
  }
}
