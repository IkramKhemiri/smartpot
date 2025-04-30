import 'package:flutter/material.dart';

class ArticleDetailScreen extends StatelessWidget {
  const ArticleDetailScreen({super.key});

  // Fonction pour simuler la récupération des données de l'article
  // En pratique, vous utiliseriez probablement une base de données ou une API
  Map<String, dynamic> _getArticleData(String articleId) {
    // Simuler des données différentes selon l'ID
    switch (articleId) {
      case '1':
        return {
          'title': 'Les secrets des succulentes',
          'image': 'assets/images/succlents.jpeg',
          'author': 'Jean Dupont',
          'date': '15 mai 2023',
          'content':
              'Les succulentes sont des plantes fascinantes qui stockent l\'eau dans leurs feuilles épaisses. Elles sont parfaites pour les débutants car elles nécessitent peu d\'entretien. Voici quelques conseils pour bien les entretenir...\n\n1. Arrosage modéré\n2. Beaucoup de lumière\n3. Bon drainage\n4. Protection contre le froid',
        };
      case '2':
        return {
          'title': 'Guide des plantes d\'intérieur',
          'image': 'assets/images/indoor_plants.jpeg',
          'author': 'Marie Leroy',
          'date': '10 mai 2023',
          'content':
              'Les plantes d\'intérieur apportent de la vie à votre maison tout en purifiant l\'air. Découvrez notre sélection des meilleures plantes pour chaque pièce...',
        };
      default:
        return {
          'title': 'Article introuvable',
          'image': 'assets/images/default_plant.jpeg',
          'author': '',
          'date': '',
          'content': 'Cet article n\'existe pas ou a été supprimé.',
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    // Récupérer l'ID de l'article passé en argument
    final articleId = ModalRoute.of(context)!.settings.arguments as String;
    final article = _getArticleData(articleId);

    return Scaffold(
      appBar: AppBar(
        title: Text(article['title']),
        backgroundColor: const Color(0xFF16A34A),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'article-image-$articleId',
              child: Image.asset(
                article['image'],
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article['title'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Par ${article['author']}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        article['date'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    article['content'],
                    style: const TextStyle(fontSize: 16, height: 1.6),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Action pour partager l'article
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Partager cet article'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
