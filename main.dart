import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const TrackifyApp());

class TrackifyApp extends StatelessWidget {
  const TrackifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trackify', // Updated Name
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0f172a),
      ),
      home: const LoginScreen(),
    );
  }
}

// 1. LOGIN SCREEN
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _plateController = TextEditingController();

  void _login() {
    if (_plateController.text.length >= 4) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Dashboard()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter valid Bus Plate")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "TRACKIFY Login",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                controller: _plateController,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Bus Plate Number",
                ),
                style: const TextStyle(color: Colors.black),
              ),
            ),
            ElevatedButton(onPressed: _login, child: const Text("Start Shift")),
          ],
        ),
      ),
    );
  }
}

// 2. DASHBOARD
class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  Future<void> _makeAdminCall() async {
    final Uri url = Uri(scheme: 'tel', path: '9976787741');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trackify Safety Monitor")),
      body: Column(
        children: [
          // FIXED MAP WIDGET
          SizedBox(
            height: 250,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(11.0168, 76.9558),
                initialZoom: 13,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName:
                      'com.example.trackify', // Required in newer versions
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.all(10),
            child: Text("Bus Status", style: TextStyle(fontSize: 18)),
          ),

          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(10),
              children: [
                _buildSensorCard("Engine Temp", "Normal", Colors.green),
                _buildSensorCard("Oil Pressure", "Stable", Colors.green),
                _buildSensorCard("Brake Pressure", "Normal", Colors.green),
                _buildSensorCard("Tyre Condition", "Good", Colors.green),
                _buildSensorCard("Fuel Leak", "None", Colors.green),
                _buildSensorCard("Crash Status", "No Impact", Colors.green),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _makeAdminCall,
        backgroundColor: Colors.blue,
        label: const Text("Call Admin"),
        icon: const Icon(Icons.phone),
      ),
    );
  }

  Widget _buildSensorCard(String title, String status, Color color) {
    return Card(
      color: color.withOpacity(0.2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title),
          Text(status, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
