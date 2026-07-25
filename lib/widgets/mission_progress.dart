import 'package:flutter/material.dart';

class MissionProgress extends StatelessWidget {
  const MissionProgress({super.key});

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
                Icon(Icons.timeline, color: Colors.orangeAccent, size: 26),
                SizedBox(width: 10),
                Text(
                  "Mission Progress",
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

            _statusRow("Mission", "Searching"),
            _statusRow("Rooms Scanned", "7 / 15"),
            _statusRow("Coverage", "48%"),
            _statusRow("Mission Time", "04:25"),
            _statusRow("ETA", "06:00"),
            _statusRow("Target Zone", "Sector B"),
            _statusRow("Current Task", "Thermal Scan"),
            _statusRow("Objects Detected", "12"),
            _statusRow("Survivors", "3"),
            _statusRow("Mission Status", "Running"),

            const SizedBox(height: 18),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Coverage",
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),

                const SizedBox(height: 8),

                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: const LinearProgressIndicator(
                    value: 0.48,
                    minHeight: 10,
                    backgroundColor: Color(0xFF2F3647),
                    valueColor: AlwaysStoppedAnimation(Colors.greenAccent),
                  ),
                ),

                const SizedBox(height: 6),

                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "48%",
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
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
