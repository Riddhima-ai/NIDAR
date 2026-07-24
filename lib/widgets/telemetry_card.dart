import 'package:flutter/material.dart';
import 'package:nidar/models/drone_data.dart';

class TelemetryCard extends StatelessWidget {
  final DroneData droneData;

  const TelemetryCard({
    super.key,
    required this.droneData,
  });

  Widget telemetryRow(
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
              "Telemetry",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            const Divider(color: Colors.white24),

            telemetryRow(
              Icons.battery_full,
              "Battery",
              "${droneData.battery} %",
              Colors.green,
            ),

            telemetryRow(
              Icons.height,
              "Altitude",
              "${droneData.altitude} m",
              Colors.orange,
            ),

            telemetryRow(
              Icons.speed,
              "Speed",
              "${droneData.speed} m/s",
              Colors.blue,
            ),

            telemetryRow(
              Icons.explore,
              "Heading",
              "${droneData.heading}°",
              Colors.purple,
            ),

            telemetryRow(
              Icons.satellite_alt,
              "GPS Satellites",
              "${droneData.gpsSatellites}",
              Colors.amber,
            ),

            telemetryRow(
              droneData.connected
                  ? Icons.check_circle
                  : Icons.cancel,
              "Status",
              droneData.connected
                  ? "Connected"
                  : "Disconnected",
              droneData.connected
                  ? Colors.green
                  : Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}