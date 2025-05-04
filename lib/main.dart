import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/models/article.dart';
import 'screens/home/plant_category_screen.dart';
import 'screens/home/all_articles.dart';
import 'screens/home/ask_ai_screen.dart';
import 'screens/home/article_detail_screen.dart';
import 'screens/home/notification_screen.dart';
import 'package:smartpot/screens/home/dashboard.dart';
import 'package:smartpot/screens/plant/plants_list_screen.dart';
import 'package:smartpot/screens/account/my_profile_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Configuration des notifications locales
  await _initializeNotifications();

  runApp(const PlantifyApp());
}

Future<void> _initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      // Gérer le clic sur les notifications ici si nécessaire
    },
  );
}

class PlantifyApp extends StatelessWidget {
  const PlantifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plantify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF16A34A),
          elevation: 0,
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const PlantifyHomePage(),
        '/plant_category': (context) => const PlantCategoryScreen(),
        '/all_articles': (context) => const AllArticlesScreen(),
        '/ask_ai': (context) => const AskAiScreen(),
        '/article_detail':
            (context) => ArticleDetailScreen(
              article: ModalRoute.of(context)!.settings.arguments as Article,
            ),
        '/notifications': (context) => const NotificationScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/my_plants': (context) => MyPlantsScreen(),
        '/account': (context) => AccountScreen(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder:
              (context) => Scaffold(
                appBar: AppBar(title: const Text('Erreur')),
                body: Center(child: Text('Page non trouvée: ${settings.name}')),
              ),
        );
      },
    );
  }
}
