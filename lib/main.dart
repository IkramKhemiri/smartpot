import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'theme/theme.dart'; // Ton fichier de thème
import 'screens/entry_screen.dart'; // L'écran de démarrage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const PlantifyApp());
}

class PlantifyApp extends StatelessWidget {
  const PlantifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plantify',
      theme: appTheme,
      debugShowCheckedModeBanner: false,
      home: const EntryScreen(), // on commence par EntryScreen
    );
  }
}
