import 'package:flutter/material.dart';

class Navbar extends StatelessWidget {
  final bool isConnected;
  final String missionStatus;
  final int battery;
  final String currentTime;

  const Navbar({
    super.key,
    required this.isConnected,
    required this.missionStatus,
    required this.battery,
    required this.currentTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          /// Logo
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: const Color(0xFF273244),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.flight_takeoff,
              color: Colors.cyanAccent,
              size: 30,
            ),
          ),

          const SizedBox(width: 16),

          /// Title
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "NIDAR",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),

              SizedBox(height: 2),

              Text(
                "Ground Control Station",
                style: TextStyle(color: Colors.white60, fontSize: 13),
              ),
            ],
          ),

          const Spacer(),

          _statusChip(
            icon: Icons.circle,
            text: isConnected ? "CONNECTED" : "DISCONNECTED",
            color: isConnected ? Colors.green : Colors.red,
          ),

          const SizedBox(width: 14),

          _statusChip(
            icon: Icons.flag,
            text: missionStatus,
            color: Colors.orangeAccent,
          ),

          const SizedBox(width: 25),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.battery_full,
                    color: Colors.greenAccent,
                    size: 18,
                  ),

                  const SizedBox(width: 6),

                  Text(
                    "$battery%",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 5),

              SizedBox(
                width: 90,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: battery / 100,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade800,
                    valueColor: const AlwaysStoppedAnimation(
                      Colors.greenAccent,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 25),

          Column(
            children: [
              const Icon(
                Icons.access_time,
                color: Colors.orangeAccent,
                size: 20,
              ),

              const SizedBox(height: 5),

              Text(currentTime, style: const TextStyle(color: Colors.white)),
            ],
          ),

          const SizedBox(width: 25),

          Column(
            children: const [
              Icon(Icons.network_wifi, color: Colors.cyanAccent, size: 20),

              SizedBox(height: 5),

              Text("Strong", style: TextStyle(color: Colors.white)),
            ],
          ),

          const SizedBox(width: 20),

          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF232B3A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.settings, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _statusChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(.15),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: color),

          const SizedBox(width: 8),

          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
