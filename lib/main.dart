import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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

// 1. Gestionnaire de messages en arrière-plan
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _setupNotifications();
  _showNotification(message);
}

// 2. Configuration des notifications
Future<void> _setupNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (response) {
      // Gestion du clic sur notification
    },
  );

  // Création du canal de notification (Android 8.0+)
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'plant_alerts_channel',
    'Plant Alerts',
    description: 'Notifications for plant monitoring alerts',
    importance: Importance.high,
    playSound: true,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);
}

// 3. Affichage des notifications
void _showNotification(RemoteMessage message) {
  final notification = message.notification;
  final android = message.notification?.android;

  if (notification != null && android != null) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'plant_alerts_channel',
          'Plant Alerts',
          icon: android.smallIcon,
          color: Colors.green,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}

// 4. Configuration de Firebase Messaging
Future<void> _configureFirebaseMessaging() async {
  // Demande des permissions
  final settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  debugPrint('Permission status: ${settings.authorizationStatus}');

  // Écouteurs pour les différents états
  FirebaseMessaging.onMessage.listen(_showNotification);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpen);

  // Récupération du token
  final token = await FirebaseMessaging.instance.getToken();
  debugPrint('FCM Token: $token');

  // Gestion des notifications au lancement
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    _handleNotificationOpen(initialMessage);
  }
}

void _handleNotificationOpen(RemoteMessage message) {
  debugPrint('Notification opened: ${message.notification?.title}');
  // Navigation vers l'écran approprié
}

Future<void> _initializeApp() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _setupNotifications();
  await _configureFirebaseMessaging();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await _initializeApp();
    runApp(const PlantifyApp());
  } catch (e) {
    runApp(
      MaterialApp(
        home: Scaffold(body: Center(child: Text('Erreur: ${e.toString()}'))),
      ),
    );
  }
}

class PlantifyApp extends StatelessWidget {
  const PlantifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plantify',
      debugShowCheckedModeBanner: false,
      theme: _buildAppTheme(),
      home: const SplashScreen(),
      routes: _buildAppRoutes(),
      onUnknownRoute: _buildUnknownRouteHandler(),
    );
  }

  ThemeData _buildAppTheme() {
    return ThemeData(
      primarySwatch: Colors.green,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF16A34A),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF16A34A),
      ),
    );
  }

  Map<String, WidgetBuilder> _buildAppRoutes() {
    return {
      '/home': (context) => const PlantifyHomePage(),
      '/plant_category': (context) => const PlantCategoryScreen(),
      '/all_articles': (context) => const AllArticlesScreen(),
      '/ask_ai': (context) => const AskAiScreen(),
      '/article_detail':
          (context) => ArticleDetailScreen(
            article: ModalRoute.of(context)!.settings.arguments as Article,
          ),
      '/notifications': (context) => const NotificationScreen(),
      '/dashboard': (context) => const DashboardScreen(),
      '/my_plants': (context) => const MyPlantsScreen(),
      '/account': (context) => const AccountScreen(),
    };
  }

  Route<dynamic> Function(RouteSettings) _buildUnknownRouteHandler() {
    return (settings) => MaterialPageRoute(
      builder:
          (context) => Scaffold(
            appBar: AppBar(title: const Text('Erreur')),
            body: Center(
              child: Text(
                'Page non trouvée: ${settings.name}',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
    );
  }
}
