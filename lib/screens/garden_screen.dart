import 'package:flutter/material.dart';
import '../models/plant.dart';
import '../widgets/plant_card.dart';

class GardenScreen extends StatelessWidget {
  final List<Plant> plants = [
    Plant(name: 'Basil', waterLevel: 60, sunlightLevel: 40),
    Plant(name: 'Cactus', waterLevel: 20, sunlightLevel: 80),
    Plant(name: 'Aloe Vera', waterLevel: 30, sunlightLevel: 60),
  ];

  GardenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Garden')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: plants.length,
          itemBuilder: (context, index) {
            return PlantCard(plant: plants[index]);
          },
        ),
      ),
    );
  }
}
