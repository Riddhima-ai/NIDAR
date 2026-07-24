import 'package:flutter/material.dart';
import 'package:nidar/services/mock_data.dart';
import 'package:nidar/widgets/coordinate_display.dart';
import 'package:nidar/widgets/telemetry_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard"),),
      body: Column(
        children: [
          TelemetryCard(droneData: MockData.drone),
          CoordinatePanel(droneData:MockData.drone )
        ],
      ),
    );
  }
}