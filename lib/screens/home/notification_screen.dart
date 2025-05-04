import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref(
    'sensors_data',
  );
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Configuration des seuils
  double minHumidity = 30.0;
  double maxHumidity = 70.0;
  double minTemperature = 15.0;
  double maxTemperature = 30.0;
  double minSoilMoisture = 20.0;
  double maxSoilMoisture = 80.0;
  double minLuminosity = 100.0;
  double maxLuminosity = 1000.0;

  List<Map<String, dynamic>> notifications = [];
  bool loading = true;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadInitialData();
  }

  @override
  void dispose() {
    _dbRef.onValue.drain();
    super.dispose();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _loadInitialData() async {
    try {
      final snapshot = await _dbRef.orderByKey().limitToLast(10).once();
      if (snapshot.snapshot.exists) {
        final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
        _processData(data);
      }
      _startRealtimeListener();
    } catch (error) {
      _handleError(error);
    } finally {
      setState(() => loading = false);
    }
  }

  void _startRealtimeListener() {
    if (_isListening) return;

    _dbRef.limitToLast(1).onValue.listen((event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        _processData(data);
      }
    }, onError: _handleError);

    _isListening = true;
  }

  void _processData(Map<dynamic, dynamic> data) {
    final latestEntry = data.values.last as Map<dynamic, dynamic>;

    final humidity = latestEntry['humidity']?.toDouble();
    final temperature = latestEntry['temperature']?.toDouble();
    final soilMoisture = latestEntry['soilMoisture']?.toDouble();
    final luminosity = latestEntry['luminosity']?.toDouble();

    if (humidity != null &&
        temperature != null &&
        soilMoisture != null &&
        luminosity != null) {
      _checkThresholdsAndNotify(
        humidity,
        temperature,
        soilMoisture,
        luminosity,
      );
    }
  }

  void _checkThresholdsAndNotify(
    double humidity,
    double temperature,
    double soilMoisture,
    double luminosity,
  ) {
    final now = DateTime.now();
    final timeString = DateFormat('HH:mm').format(now);

    // Vérification humidité
    if (humidity < minHumidity) {
      _addNotification(
        'Humidité trop basse',
        '${humidity.toStringAsFixed(1)}% (min: $minHumidity%)',
        false,
        now,
      );
    } else if (humidity > maxHumidity) {
      _addNotification(
        'Humidité trop élevée',
        '${humidity.toStringAsFixed(1)}% (max: $maxHumidity%)',
        false,
        now,
      );
    }

    // Vérification température
    if (temperature < minTemperature) {
      _addNotification(
        'Température trop basse',
        '${temperature.toStringAsFixed(1)}°C (min: $minTemperature°C)',
        false,
        now,
      );
    } else if (temperature > maxTemperature) {
      _addNotification(
        'Température trop élevée',
        '${temperature.toStringAsFixed(1)}°C (max: $maxTemperature°C)',
        false,
        now,
      );
    }

    // Vérification humidité du sol
    if (soilMoisture < minSoilMoisture) {
      _addNotification(
        'Sol trop sec',
        '${soilMoisture.toStringAsFixed(1)}% (min: $minSoilMoisture%)',
        false,
        now,
      );
    } else if (soilMoisture > maxSoilMoisture) {
      _addNotification(
        'Sol trop humide',
        '${soilMoisture.toStringAsFixed(1)}% (max: $maxSoilMoisture%)',
        false,
        now,
      );
    }

    // Vérification luminosité
    if (luminosity < minLuminosity) {
      _addNotification(
        'Luminosité faible',
        '${luminosity.toStringAsFixed(1)} lux (min: $minLuminosity lux)',
        false,
        now,
      );
    } else if (luminosity > maxLuminosity) {
      _addNotification(
        'Luminosité forte',
        '${luminosity.toStringAsFixed(1)} lux (max: $maxLuminosity lux)',
        false,
        now,
      );
    }
  }

  void _addNotification(
    String title,
    String message,
    bool read,
    DateTime timestamp,
  ) {
    setState(() {
      notifications.insert(0, {
        'title': title,
        'message': message,
        'time': _formatTimestamp(timestamp),
        'timestamp': timestamp,
        'read': read,
        'type': _getNotificationType(title),
      });
    });

    _showLocalNotification(title, message);
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (timestamp.isAfter(today)) {
      return 'Aujourd\'hui à ${DateFormat('HH:mm').format(timestamp)}';
    } else if (timestamp.isAfter(yesterday)) {
      return 'Hier à ${DateFormat('HH:mm').format(timestamp)}';
    } else {
      return DateFormat('dd/MM/yyyy à HH:mm').format(timestamp);
    }
  }

  String _getNotificationType(String title) {
    if (title.contains('Humidité')) return 'humidity';
    if (title.contains('Température')) return 'temperature';
    if (title.contains('Sol')) return 'soil';
    if (title.contains('Luminosité')) return 'light';
    return 'general';
  }

  Future<void> _showLocalNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'sensor_alerts',
          'Alertes Capteurs',
          importance: Importance.high,
          priority: Priority.high,
          colorized: true,
          color: Color(0xFF16A34A),
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  void _markAsRead(int index) {
    setState(() {
      notifications[index]['read'] = true;
    });
  }

  void _deleteNotification(int index) {
    setState(() {
      notifications.removeAt(index);
    });
  }

  void _handleError(dynamic error) {
    debugPrint('Firebase error: $error');
    _addNotification(
      'Erreur de connexion',
      'Impossible de récupérer les données des capteurs',
      true,
      DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertes Capteurs'),
        backgroundColor: const Color(0xFF16A34A),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () => _showFilterDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(),
          ),
        ],
      ),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : notifications.isEmpty
              ? const Center(
                child: Text(
                  'Aucune alerte pour le moment',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadInitialData,
                child: ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return Dismissible(
                      key: Key('${notification['timestamp']}-$index'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) => _deleteNotification(index),
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        elevation: notification['read'] ? 1 : 2,
                        color:
                            notification['read']
                                ? Colors.white
                                : Colors.green[50],
                        child: ListTile(
                          leading: _buildNotificationIcon(notification['type']),
                          title: Text(
                            notification['title'],
                            style: TextStyle(
                              fontWeight:
                                  notification['read']
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(notification['message']),
                              const SizedBox(height: 4),
                              Text(
                                notification['time'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          trailing:
                              !notification['read']
                                  ? const Icon(
                                    Icons.circle,
                                    size: 10,
                                    color: Colors.green,
                                  )
                                  : null,
                          onTap: () => _markAsRead(index),
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }

  Widget _buildNotificationIcon(String type) {
    IconData icon;
    Color color;

    switch (type) {
      case 'humidity':
        icon = Icons.water_drop;
        color = Colors.blue;
        break;
      case 'temperature':
        icon = Icons.thermostat;
        color = Colors.orange;
        break;
      case 'soil':
        icon = Icons.grass;
        color = Colors.brown;
        break;
      case 'light':
        icon = Icons.light_mode;
        color = Colors.yellow[700]!;
        break;
      default:
        icon = Icons.notifications;
        color = Colors.green;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.2),
      child: Icon(icon, color: color),
    );
  }

  Future<void> _showFilterDialog() async {
    final types = {
      'Tous': 'all',
      'Humidité': 'humidity',
      'Température': 'temperature',
      'Sol': 'soil',
      'Luminosité': 'light',
    };
    String? selectedType = 'all';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filtrer les alertes'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  types.entries.map((entry) {
                    return RadioListTile<String>(
                      title: Text(entry.key),
                      value: entry.value,
                      groupValue: selectedType,
                      onChanged: (value) {
                        Navigator.pop(context);
                        selectedType = value;
                        // Implémentez le filtrage ici
                      },
                    );
                  }).toList(),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showSettingsDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Paramètres des seuils'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildThresholdSetting(
                  'Humidité (%)',
                  minHumidity,
                  maxHumidity,
                  (min, max) {
                    setState(() {
                      minHumidity = min;
                      maxHumidity = max;
                    });
                  },
                ),
                _buildThresholdSetting(
                  'Température (°C)',
                  minTemperature,
                  maxTemperature,
                  (min, max) {
                    setState(() {
                      minTemperature = min;
                      maxTemperature = max;
                    });
                  },
                ),
                _buildThresholdSetting(
                  'Humidité sol (%)',
                  minSoilMoisture,
                  maxSoilMoisture,
                  (min, max) {
                    setState(() {
                      minSoilMoisture = min;
                      maxSoilMoisture = max;
                    });
                  },
                ),
                _buildThresholdSetting(
                  'Luminosité (lux)',
                  minLuminosity,
                  maxLuminosity,
                  (min, max) {
                    setState(() {
                      minLuminosity = min;
                      maxLuminosity = max;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildThresholdSetting(
    String label,
    double currentMin,
    double currentMax,
    Function(double, double) onChanged,
  ) {
    final minController = TextEditingController(
      text: currentMin.toStringAsFixed(1),
    );
    final maxController = TextEditingController(
      text: currentMax.toStringAsFixed(1),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: minController,
                  decoration: const InputDecoration(labelText: 'Min'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final min = double.tryParse(value) ?? currentMin;
                    final max =
                        double.tryParse(maxController.text) ?? currentMax;
                    onChanged(min, max);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: maxController,
                  decoration: const InputDecoration(labelText: 'Max'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final min =
                        double.tryParse(minController.text) ?? currentMin;
                    final max = double.tryParse(value) ?? currentMax;
                    onChanged(min, max);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
