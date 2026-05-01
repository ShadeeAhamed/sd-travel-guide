import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SosScreen extends StatelessWidget {
  const SosScreen({super.key});

  Future<void> _callNumber(BuildContext context, String number) async {
    final Uri uri = Uri.parse("tel:$number");

    if (!await launchUrl(uri)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open phone dialer")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency / SOS"),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 90,
            ),
            const SizedBox(height: 10),
            const Text(
              "Emergency Help",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Tap a service to open the phone dialer",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            _sosButton(
              context,
              "Police",
              "119",
              Icons.local_police,
              Colors.blue,
            ),
            _sosButton(
              context,
              "Ambulance",
              "1990",
              Icons.local_hospital,
              Colors.red,
            ),
            _sosButton(
              context,
              "Fire Brigade",
              "110",
              Icons.fire_extinguisher,
              Colors.orange,
            ),
            _sosButton(
              context,
              "Tourist Police",
              "1912",
              Icons.travel_explore,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sosButton(
    BuildContext context,
    String title,
    String number,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: () => _callNumber(context, number),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              "$title ($number)",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
