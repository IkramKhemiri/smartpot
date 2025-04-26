import 'package:flutter/material.dart';
import '../models/plant.dart';
import '../screens/plant_details_screen.dart';

class PlantCard extends StatelessWidget {
  final Plant plant;

  const PlantCard({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.local_florist, color: Colors.green),
        title: Text(plant.name),
        subtitle: Text('Water: ${plant.waterLevel}%, Sunlight: ${plant.sunlightLevel}%'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PlantDetailsScreen(
                name: plant.name,
                waterLevel: plant.waterLevel,
                sunlightLevel: plant.sunlightLevel,
              ),
            ),
          );
        },
      ),
    );
  }
}
