import 'package:flutter/material.dart';
import '../models/plant.dart';
import '../widgets/plant_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Garden")),
      body: ListView(
        children: [
  PlantCard(
    plant: Plant(name: 'Oreo', waterLevel: 70, sunlightLevel: 60),
  ),
  PlantCard(
    plant: Plant(name: 'Flora', waterLevel: 50, sunlightLevel: 90),
  ),
],

      ),
    );
  }
}
