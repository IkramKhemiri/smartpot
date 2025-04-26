import 'package:flutter/material.dart';
import 'screens/splash_screen.dart'; // importe ton SplashScreen

void main() {
  runApp(const PlantifyApp());
}

class PlantifyApp extends StatelessWidget {
  const PlantifyApp({super.key}); // ← simplifié ici

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plantify',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(), // ici on lance ton SplashScreen
    );
  }
}
