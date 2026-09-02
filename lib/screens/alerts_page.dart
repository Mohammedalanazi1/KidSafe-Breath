import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  AlertsPageState createState() => AlertsPageState();
}

class AlertsPageState extends State<AlertsPage> {
  final DatabaseReference _alertsRef = FirebaseDatabase.instance.ref('alerts');
  List<Map<String, dynamic>> alerts = [];

  
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadNotificationSetting(); 
    _listenToAlerts();
  }

  
  void _initializeNotifications() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(android: androidInit);

    await flutterLocalNotificationsPlugin.initialize(settings);
  }

  
  Future<void> _loadNotificationSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

 
  Future<void> _showAlertNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'health_alerts_channel',
      'Health Alerts',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(0, title, body, platformDetails);
  }

  void _listenToAlerts() {
    _alertsRef.onValue.listen((event) {
      final Object? rawData = event.snapshot.value;

      if (rawData is Map) {
        final List<Map<String, dynamic>> loadedAlerts = [];

        rawData.forEach((key, value) {
          if (value is Map) {
            final alert = Map<String, dynamic>.from(
              value.map((k, v) => MapEntry(k.toString(), v)),
            );

            if ((alert["message"] ?? "").toString().isNotEmpty &&
                (alert["time"] ?? "").toString().isNotEmpty) {
              final newAlert = {
                "type": alert["type"] ?? "Alert",
                "message": alert["message"] ?? "",
                "time": alert["time"] ?? "",
                "timestampMillis": alert["timestampMillis"] ?? 0,
                "icon": _getIcon(alert["icon"]),
                "color": _getColor(alert["color"]),
              };

              
              if (_notificationsEnabled &&
                  (newAlert["type"] == "Suffocation Alert" ||
                   newAlert["type"] == "Health Alert")) {
                _showAlertNotification(
                  newAlert["type"],
                  newAlert["message"],
                );
              }

              loadedAlerts.add(newAlert);
            }
          }
        });

        loadedAlerts.sort((a, b) =>
            (b["timestampMillis"] ?? 0).compareTo(a["timestampMillis"] ?? 0));

        setState(() {
          alerts = loadedAlerts;
        });
      } else {
        setState(() {
          alerts = [];
        });
      }
    });
  }

  IconData _getIcon(String? iconName) {
    switch (iconName) {
      case "warning":
        return Icons.warning;
      case "favorite":
        return Icons.favorite;
      case "info":
        return Icons.info;
      case "lungs":
        return Icons.sick;
      default:
        return Icons.notification_important;
    }
  }

  Color _getColor(String? colorName) {
    switch (colorName) {
      case "orange":
        return Colors.orange;
      case "red":
        return Colors.red;
      case "blue":
        return Colors.blue;
      case "darkred":
        return const Color(0xFF8B0000);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8EA7B5),
      appBar: AppBar(
        title: Text("Health Alerts", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF8EA7B5),
        centerTitle: true,
        elevation: 0,
      ),
      body: alerts.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: ListView.builder(
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          final alert = alerts[index];
          return _buildAlertCard(alert);
        },
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    final bool isSuffocation = alert["type"] == "Suffocation Alert";

    return Card(
      color: isSuffocation
          ? alert["color"].withOpacity(0.9)
          // ignore: deprecated_member_use
          : Colors.white.withOpacity(0.96),
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: Icon(alert["icon"], color: isSuffocation ? Colors.white : alert["color"], size: 40),
        title: Text(
          alert["type"],
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isSuffocation ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              alert["message"],
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: isSuffocation ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              alert["time"],
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: isSuffocation ? Colors.white60 : Colors.grey,
              ),
            ),
          ],
        ),
        onTap: () => _showAlertDetails(alert),
      ),
    );
  }

  void _showAlertDetails(Map<String, dynamic> alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          alert["type"],
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF8EA7B5),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Message: ${alert["message"]}", style: GoogleFonts.poppins(fontSize: 15)),
            const SizedBox(height: 8),
            Text("Time: ${alert["time"]}", style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK", style: GoogleFonts.poppins(color: const Color(0xFF8EA7B5))),
          ),
        ],
      ),
    );
  }
}
