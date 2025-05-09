import 'dart:math'; // Pour Random

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
// import 'firebase_options.dart'; // Décommente si tu as généré ce fichier avec FlutterFire CLI

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform, // Décommente si tu as le fichier firebase_options.dart
  );
  runApp(const SmartPotApp()); // ✅ Correction ici
}

class SmartPotApp extends StatelessWidget {
  const SmartPotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Pot Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AutoWateringSystem(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AutoWateringSystem extends StatefulWidget {
  const AutoWateringSystem({super.key});

  @override
  State<AutoWateringSystem> createState() => _AutoWateringSystemState();
}

class _AutoWateringSystemState extends State<AutoWateringSystem> {
  final DatabaseReference _smartPotRef = FirebaseDatabase.instance.ref('smartpot');
  final DatabaseReference _pumpRef = FirebaseDatabase.instance.ref('pump_control');
  final Random _random = Random();

  bool _pumpActive = false;
  bool _autoMode = true;
  double _soilMoisture = 61.0;
  double _temperature = 20.9;
  double _humidity = 79.2;
  int _waterAmount = 100;
  double _moistureThreshold = 30.0;

  @override
  void initState() {
    super.initState();
    _setupMockData();
    _setupListeners();
  }

  void _setupMockData() {
    _smartPotRef.set({
      'soilMoisture': _soilMoisture,
      'temperature': _temperature,
      'humidity': _humidity,
    });

    _pumpRef.set({
      'status': _pumpActive,
      'water_amount': 0,
      'mode': _autoMode ? 'auto' : 'manual'
    });
  }

  void _setupListeners() {
    _smartPotRef.onValue.listen((event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          _soilMoisture = (data['soilMoisture'] ?? 0.0).toDouble();
          _temperature = (data['temperature'] ?? 0.0).toDouble();
          _humidity = (data['humidity'] ?? 0.0).toDouble();
        });

        if (_autoMode) _checkSoilMoisture();
      }
    });

    _pumpRef.child('status').onValue.listen((event) {
      if (event.snapshot.exists) {
        setState(() {
          _pumpActive = event.snapshot.value as bool;
        });
      }
    });
  }

  void _checkSoilMoisture() {
    if (_soilMoisture < _moistureThreshold && !_pumpActive) {
      _controlPump(true, _waterAmount);
    } else if (_soilMoisture >= _moistureThreshold && _pumpActive) {
      _controlPump(false);
    }
  }

  Future<void> _controlPump(bool activate, [int amount = 0]) async {
    try {
      await _pumpRef.update({
        'status': activate,
        if (activate) 'water_amount': amount,
        'timestamp': ServerValue.timestamp,
        'mode': _autoMode ? 'auto' : 'manual'
      });

      if (activate) {
        Future.delayed(const Duration(seconds: 3), () {
          _smartPotRef.update({
            'soilMoisture': _soilMoisture + 20.0,
          });
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  void _simulateEnvironmentChange() {
    final newMoisture = _soilMoisture - 15.0;
    _smartPotRef.update({
      'soilMoisture': newMoisture > 0 ? newMoisture : 0.0,
      'temperature': _temperature + _random.nextDouble() * 2 - 1,
      'humidity': _humidity + _random.nextDouble() * 5 - 2.5,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pump control'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _simulateEnvironmentChange,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSensorPanel(),
            const SizedBox(height: 20),
            _buildControlPanel(),
            if (!_autoMode) _buildManualControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorPanel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSensorTile('Humidité Sol', '$_soilMoisture%', Icons.grass,
                _soilMoisture < _moistureThreshold ? Colors.red : Colors.green),
            _buildSensorTile('Température', '${_temperature.toStringAsFixed(1)}°C',
                Icons.thermostat, Colors.orange),
            _buildSensorTile('Humidité Air', '${_humidity.toStringAsFixed(1)}%',
                Icons.opacity, Colors.blue),
            const Divider(),
            _buildStatusIndicator('Pompe', _pumpActive ? 'ACTIVE' : 'INACTIVE',
                _pumpActive ? Colors.green : Colors.red),
            _buildStatusIndicator('Mode', _autoMode ? 'AUTO' : 'MANUEL',
                Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('PARAMÈTRES', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildSliderControl(
              'Seuil d\'humidité: ${_moistureThreshold.round()}%',
              _moistureThreshold,
              0,
              100,
              (value) => setState(() => _moistureThreshold = value),
            ),
            _buildSliderControl(
              'Quantité d\'eau: $_waterAmount ml',
              _waterAmount.toDouble(),
              50,
              500,
              (value) => setState(() => _waterAmount = value.toInt()),
            ),
            SwitchListTile(
              title: const Text('Mode Automatique'),
              value: _autoMode,
              onChanged: (value) => setState(() => _autoMode = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualControls() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('ACTIVER'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: () => _controlPump(true, _waterAmount),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.stop),
              label: const Text('ARRÊTER'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: () => _controlPump(false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorTile(String title, String value, IconData icon, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      trailing: Text(value, style: TextStyle(
        fontWeight: FontWeight.bold,
        color: color,
      )),
    );
  }

  Widget _buildStatusIndicator(String title, String value, Color color) {
    return ListTile(
      title: Text(title),
      trailing: Chip(
        label: Text(value),
        backgroundColor: color.withOpacity(0.2),
        labelStyle: TextStyle(color: color),
      ),
    );
  }

  Widget _buildSliderControl(String label, double value, double min, double max,
      Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).toInt() ~/ 10,
          label: value.round().toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
