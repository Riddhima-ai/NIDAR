import 'package:flutter/material.dart';

class MissionStatistics extends StatelessWidget {
  const MissionStatistics({super.key});

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
                Icon(Icons.analytics, color: Colors.purpleAccent, size: 26),
                SizedBox(width: 10),
                Text(
                  "Mission Statistics",
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

            Row(
              children: const [
                Expanded(
                  child: StatBox(
                    title: "Mission Time",
                    value: "18 min",
                    icon: Icons.timer,
                    color: Colors.orange,
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: StatBox(
                    title: "Coverage",
                    value: "82%",
                    icon: Icons.map,
                    color: Colors.green,
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: StatBox(
                    title: "Battery",
                    value: "68%",
                    icon: Icons.battery_full,
                    color: Colors.lightGreen,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Row(
              children: const [
                Expanded(
                  child: StatBox(
                    title: "Distance",
                    value: "42.8 m",
                    icon: Icons.route,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: StatBox(
                    title: "Survivors",
                    value: "3",
                    icon: Icons.people,
                    color: Colors.redAccent,
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: StatBox(
                    title: "Signal",
                    value: "Strong",
                    icon: Icons.wifi,
                    color: Colors.cyan,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.greenAccent),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Mission running successfully. All systems operational.",
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatBox({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF232B3A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),

            const SizedBox(height: 10),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),

            const SizedBox(height: 6),

            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
