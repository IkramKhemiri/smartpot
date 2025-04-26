import 'package:flutter/material.dart';

class PlantDetailsScreen extends StatelessWidget {
  final String name;
  final int waterLevel;
  final int sunlightLevel;

  const PlantDetailsScreen({
    super.key,
    required this.name,
    required this.waterLevel,
    required this.sunlightLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB4B88A),
      appBar: AppBar(
        title: Text(name),
        backgroundColor: const Color(0xFF4A6A4A),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 240,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0E0),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF3A7A7A)),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Care Summary',
                      style: TextStyle(
                        fontFamily: 'CourierPrime',
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        fontSize: 16,
                        color: Color(0xFF4B4B4B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Image.network(
                          'https://placehold.co/24x24/4a90e2/4a90e2.png?text=💧',
                          width: 24,
                          height: 24,
                          semanticLabel: 'Water drop icon',
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Water Needs: $waterLevel%',
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'CourierPrime',
                            color: Color(0xFF4B4B4B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Image.network(
                          'https://placehold.co/24x24/f5c542/f5c542.png?text=☀',
                          width: 24,
                          height: 24,
                          semanticLabel: 'Sun icon',
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Sunlight Needs: $sunlightLevel%',
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'CourierPrime',
                            color: Color(0xFF4B4B4B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Container(
                width: 240,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0E0),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF3A7A7A)),
                ),
                child: Column(
                  children: const [
                    Text(
                      'Tips',
                      style: TextStyle(
                        fontFamily: 'CourierPrime',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF4B4B4B),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '💧 Water when the soil feels dry.\n'
                      '🌞 Place in a well-lit area but avoid direct afternoon sun.',
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'CourierPrime',
                        color: Color(0xFF4B4B4B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
