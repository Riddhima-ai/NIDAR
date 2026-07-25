import 'package:flutter/material.dart';

class DroneStatus extends StatelessWidget {
  const DroneStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1F2B),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.flight, color: Colors.cyanAccent, size: 26),
                SizedBox(width: 10),
                Text(
                  "Drone Status",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            const Divider(color: Colors.white24, thickness: 1),

            const SizedBox(height: 10),

            _statusRow("Status", "Flying"),
            _statusRow("Flight Mode", "AUTO"),
            _statusRow("Mission", "Searching"),
            _statusRow("Connection", "Connected"),
            _statusRow("Mission Time", "04:25"),
            _statusRow("Altitude", "2.4 m"),
            _statusRow("Speed", "1.2 m/s"),
            _statusRow("Heading", "90°"),
            _statusRow("GPS", "Available"),
            _statusRow("Battery", "86%"),
            _statusRow("CPU Usage", "41%"),
          ],
        ),
      ),
    );
  }

  static Widget _statusRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 180,
            child: Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 17),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
