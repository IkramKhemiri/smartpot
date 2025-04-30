import 'package:flutter/material.dart';
//import 'article_detail_screen.dart';

class AllArticlesScreen extends StatelessWidget {
  const AllArticlesScreen({super.key});

  final List<Map<String, dynamic>> articles = const [
    {
      'id': '1',
      'title': 'Les secrets des succulentes',
      'image': 'assets/images/succlents.jpeg',
      'author': 'Jean Dupont',
      'date': '15 mai 2023',
      'content': 'Contenu complet de l\'article...',
    },
    {
      'id': '2',
      'title': 'Guide des plantes d\'intérieur',
      'image': 'assets/images/indoor_plants.jpeg',
      'author': 'Marie Leroy',
      'date': '10 mai 2023',
      'content': 'Contenu complet de l\'article...',
    },
    {
      'id': '3',
      'title': 'Entretenir ses plantes en hiver',
      'image': 'assets/images/winter_plants.jpeg',
      'author': 'Pierre Martin',
      'date': '5 mai 2023',
      'content': 'Contenu complet de l\'article...',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tous les articles'),
        backgroundColor: const Color(0xFF16A34A),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/article_detail',
                  arguments: article['id'],
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Image.asset(
                      article['image'] as String,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article['title'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              article['author'] as String,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              article['date'] as String,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
