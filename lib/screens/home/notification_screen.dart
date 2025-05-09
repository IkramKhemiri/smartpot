import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref(
    'sensor_alerts',
  );
  final List<Map<String, dynamic>> _alerts = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _setupDatabaseListener();
    _checkPendingNotifications();
  }

  Future<void> _checkPendingNotifications() async {
    final details =
        await FlutterLocalNotificationsPlugin()
            .getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp ?? false) {
      _handleNotificationNavigation(details!.notificationResponse);
    }
  }

  void _handleNotificationNavigation(NotificationResponse? response) {
    if (response?.payload != null) {
      Navigator.pushNamed(context, response!.payload!);
    }
  }

  void _setupDatabaseListener() {
    _database
        .orderByChild('timestamp')
        .limitToLast(50)
        .onValue
        .listen(
          (event) {
            _processAlerts(event.snapshot);
          },
          onError: (error) {
            setState(() {
              _hasError = true;
              _isLoading = false;
            });
          },
        );
  }

  void _processAlerts(DataSnapshot snapshot) {
    final List<Map<String, dynamic>> newAlerts = [];

    if (snapshot.value != null) {
      final Map<dynamic, dynamic> data =
          snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        final alert = value as Map<dynamic, dynamic>;
        newAlerts.add({
          'id': key,
          'title': alert['title'] ?? 'Alerte',
          'message': alert['message'] ?? 'Nouvelle alerte détectée',
          'timestamp':
              alert['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
          'type': alert['type'] ?? 'general',
          'isRead': alert['isRead'] ?? false,
        });
      });
    }

    setState(() {
      _alerts.clear();
      _alerts.addAll(newAlerts.reversed.toList());
      _isLoading = false;
    });
  }

  Future<void> _markAsRead(String alertId) async {
    await _database.child(alertId).update({'isRead': true});
  }

  Future<void> _deleteAlert(String alertId) async {
    await _database.child(alertId).remove();
  }

  String _formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date.isAfter(today)) {
      return 'Aujourd\'hui à ${DateFormat('HH:mm').format(date)}';
    } else if (date.isAfter(yesterday)) {
      return 'Hier à ${DateFormat('HH:mm').format(date)}';
    } else {
      return DateFormat('dd/MM/yyyy à HH:mm').format(date);
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'temperature':
        return Icons.thermostat;
      case 'humidity':
        return Icons.water_drop;
      case 'soil':
        return Icons.grass;
      case 'light':
        return Icons.light_mode;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'temperature':
        return Colors.orange;
      case 'humidity':
        return Colors.blue;
      case 'soil':
        return Colors.brown;
      case 'light':
        return Colors.amber;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des Alertes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _confirmClearAll,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Erreur de connexion', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _retryConnection,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_alerts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off, size: 50, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucune alerte récente',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshAlerts,
      child: ListView.builder(
        itemCount: _alerts.length,
        itemBuilder: (context, index) {
          final alert = _alerts[index];
          return _buildAlertCard(alert);
        },
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    final alertColor = _getColorForType(alert['type']);

    return Dismissible(
      key: Key(alert['id']),
      background: Container(color: Colors.red),
      secondaryBackground: Container(color: Colors.green),
      confirmDismiss: (direction) => _confirmDismiss(alert['id'], direction),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        color: alert['isRead'] ? Colors.grey[100] : Colors.white,
        elevation: alert['isRead'] ? 1 : 2,
        child: InkWell(
          onTap: () => _markAsRead(alert['id']),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: alertColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIconForType(alert['type']),
                    color: alertColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert['title'],
                        style: TextStyle(
                          fontWeight:
                              alert['isRead']
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alert['message'],
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTimestamp(alert['timestamp']),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (!alert['isRead'])
                  const Icon(Icons.circle, size: 10, color: Colors.green),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDismiss(
    String alertId,
    DismissDirection direction,
  ) async {
    if (direction == DismissDirection.endToStart) {
      // Marquer comme lu
      await _markAsRead(alertId);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Alerte marquée comme lue')));
      return false; // Ne pas supprimer l'élément
    } else {
      // Supprimer
      return await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Supprimer cette alerte ?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Annuler'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Supprimer'),
                ),
              ],
            ),
      );
    }
  }

  Future<void> _confirmClearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Supprimer toutes les alertes ?'),
            content: const Text('Cette action est irréversible.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Supprimer'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await _database.remove();
      setState(() {
        _alerts.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Toutes les alertes ont été supprimées')),
      );
    }
  }

  Future<void> _refreshAlerts() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final snapshot = await _database.once();
      _processAlerts(snapshot.snapshot);
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _retryConnection() async {
    await _refreshAlerts();
  }
}
