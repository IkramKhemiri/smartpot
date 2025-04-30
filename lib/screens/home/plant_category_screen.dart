import 'package:flutter/material.dart';

class PlantCategoryScreen extends StatelessWidget {
  const PlantCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Récupération de l'argument passé depuis HomeScreen
    final categoryId = ModalRoute.of(context)?.settings.arguments as String?;

    // Sécurité : Si aucun ID n'est reçu, on affiche un message
    if (categoryId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Catégorie')),
        body: const Center(child: Text('Aucune catégorie sélectionnée.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Catégorie : $categoryId')),
      body: Center(
        child: Text('Affichage des plantes pour la catégorie : $categoryId'),
      ),
    );
  }
}
