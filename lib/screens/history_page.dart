import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final DatabaseReference _sensorRef = FirebaseDatabase.instance.ref('sensors');

  int heartRate = 0;
  int oxygenLevel = 0;
  double temperature = 0.0;

  @override
  void initState() {
    super.initState();
    _listenToRealtimeUpdates();
  }

  void _listenToRealtimeUpdates() {
    _sensorRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        setState(() {
          heartRate = data['heartRate'] ?? 0;
          oxygenLevel = data['oxygenLevel'] ?? 0;
          temperature = (data['temperature'] ?? 0.0).toDouble();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8EA7B5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8EA7B5),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Health Monitoring',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            Text(
              "Real-time Health Data",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            _buildDataCard(Icons.favorite, "Heart Rate", "$heartRate bpm", Colors.red),
            _buildDataCard(Icons.air, "Oxygen Level", "$oxygenLevel%", Colors.blue),
            _buildDataCard(Icons.thermostat, "Body Temperature", "$temperature °C", Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCard(IconData icon, String title, String value, Color iconColor) {
    return GestureDetector(
      onTap: () => _showDetailsDialog(title, value),
      child: Card(
        color: Colors.white,
        elevation: 5,
        margin: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 48),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      value,
                      style: GoogleFonts.poppins(fontSize: 22, color: Colors.black),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.info_outline, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailsDialog(String title, String value) {
    String analysis = "";

    if (title == "Heart Rate") {
      final rate = int.tryParse(value.replaceAll("bpm", "").trim()) ?? 0;
      analysis = (rate < 60 || rate > 130) ? "⚠️ Abnormal Heart Rate" : "✅ Normal Heart Rate";
    } else if (title == "Oxygen Level") {
      final level = int.tryParse(value.replaceAll("%", "").trim()) ?? 0;
      analysis = (level < 90) ? "⚠️ Low Oxygen Level" : "✅ Normal Oxygen Level";
    } else if (title == "Body Temperature") {
      final temp = double.tryParse(value.replaceAll("°C", "").trim()) ?? 0.0;
      analysis = (temp >= 38) ? "⚠️ High Temperature" : "✅ Normal Temperature";
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: GoogleFonts.poppins()),
        content: Text("Value: $value\n\nStatus: $analysis", style: GoogleFonts.poppins()),
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
