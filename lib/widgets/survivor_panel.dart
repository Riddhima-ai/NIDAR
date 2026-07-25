import 'package:flutter/material.dart';

class SurvivorPanel extends StatelessWidget {
  const SurvivorPanel({super.key});

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
                Icon(Icons.people, color: Colors.greenAccent, size: 26),
                SizedBox(width: 10),
                Text(
                  "Survivor Panel",
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

            _survivorCard(
              id: "S-001",
              location: "Room A-203",
              confidence: "98%",
              condition: "Conscious",
              status: "Confirmed",
              statusColor: Colors.green,
            ),

            const SizedBox(height: 15),

            _survivorCard(
              id: "S-002",
              location: "Hallway B",
              confidence: "91%",
              condition: "Injured",
              status: "Confirmed",
              statusColor: Colors.green,
            ),

            const SizedBox(height: 15),

            _survivorCard(
              id: "S-003",
              location: "Room C-107",
              confidence: "83%",
              condition: "Unknown",
              status: "Possible",
              statusColor: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _survivorCard({
    required String id,
    required String location,
    required String confidence,
    required String condition,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF232B3A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.green,
                child: Icon(Icons.person, color: Colors.white),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  id,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _infoRow("Location", location),

          _infoRow("Confidence", confidence),

          _infoRow("Condition", condition),
        ],
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
