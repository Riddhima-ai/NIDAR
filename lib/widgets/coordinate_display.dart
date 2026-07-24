import 'package:flutter/material.dart';
import 'package:nidar/models/drone_data.dart';

class CoordinatePanel extends StatelessWidget {
  final DroneData droneData;

  const CoordinatePanel({
    super.key,
    required this.droneData,
  });

  Widget coordinateRow(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 22,
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
              ),
            ),
          ),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xff222831),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Coordinates",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            const Divider(color: Colors.white24),

            coordinateRow(
              Icons.gps_fixed,
              "Latitude",
              droneData.latitude.toStringAsFixed(5),
              Colors.red,
            ),

            coordinateRow(
              Icons.location_on,
              "Longitude",
              droneData.longitude.toStringAsFixed(5),
              Colors.redAccent,
            ),

            coordinateRow(
              Icons.grid_on,
              "Grid Cell",
              "B4",
              Colors.green,
            ),

            coordinateRow(
              Icons.meeting_room,
              "Current Room",
              "Room 3",
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
}