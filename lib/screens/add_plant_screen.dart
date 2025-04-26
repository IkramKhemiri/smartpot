import 'package:flutter/material.dart';

class AddPlantScreen extends StatefulWidget {
  const AddPlantScreen({super.key});

  @override
  State<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final TextEditingController _nameController = TextEditingController();
  double _waterLevel = 50;
  double _sunlightLevel = 50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add a Plant')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Plant name'),
            ),
            const SizedBox(height: 20),
            Text('Water Needs: ${_waterLevel.round()}%'),
            Slider(
              value: _waterLevel,
              min: 0,
              max: 100,
              divisions: 10,
              onChanged: (val) {
                setState(() {
                  _waterLevel = val;
                });
              },
            ),
            const SizedBox(height: 20),
            Text('Sunlight Needs: ${_sunlightLevel.round()}%'),
            Slider(
              value: _sunlightLevel,
              min: 0,
              max: 100,
              divisions: 10,
              onChanged: (val) {
                setState(() {
                  _sunlightLevel = val;
                });
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Tu peux sauvegarder ici dans Firestore ou local DB
                Navigator.pop(context);
              },
              child: const Text('Save Plant'),
            ),
          ],
        ),
      ),
    );
  }
}
