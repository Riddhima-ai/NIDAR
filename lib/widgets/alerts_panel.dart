import 'package:flutter/material.dart';

class AlertsPanel extends StatelessWidget {
  const AlertsPanel({super.key});

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
                Icon(
                  Icons.notifications_active,
                  color: Colors.redAccent,
                  size: 26,
                ),
                SizedBox(width: 10),
                Text(
                  "Alerts Panel",
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

            _alertTile(
              icon: Icons.play_circle_fill,
              title: "Mission Started",
              subtitle: "Mission launched successfully",
              time: "12:30",
              color: Colors.green,
            ),

            const SizedBox(height: 12),

            _alertTile(
              icon: Icons.person_search,
              title: "Survivor Detected",
              subtitle: "Room A-203 • Confidence 98%",
              time: "12:34",
              color: Colors.orange,
            ),

            const SizedBox(height: 12),

            _alertTile(
              icon: Icons.warning_amber,
              title: "Obstacle Detected",
              subtitle: "Drone changed route safely",
              time: "12:36",
              color: Colors.amber,
            ),

            const SizedBox(height: 12),

            _alertTile(
              icon: Icons.battery_alert,
              title: "Battery Warning",
              subtitle: "Battery dropped below 30%",
              time: "12:40",
              color: Colors.redAccent,
            ),

            const SizedBox(height: 12),

            _alertTile(
              icon: Icons.wifi,
              title: "Communication Stable",
              subtitle: "Signal strength is good",
              time: "Now",
              color: Colors.cyanAccent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _alertTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF232B3A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withOpacity(.2),
            child: Icon(icon, color: color, size: 22),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          Text(
            time,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
