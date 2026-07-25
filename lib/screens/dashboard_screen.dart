import 'package:flutter/material.dart';

import '../widgets/navbar.dart';
import '../widgets/drone_status.dart';
import '../widgets/mission_progress.dart';
import '../widgets/survivor_panel.dart';
import '../widgets/alerts_panel.dart';
import '../widgets/mission_statistics.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Navbar(
                isConnected: true,
                missionStatus: "RUNNING",
                battery: 86,
                currentTime: "12:43",
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // First Row
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Expanded(child: DroneStatus()),

                          SizedBox(width: 20),

                          Expanded(child: MissionProgress()),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // Second Row
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Expanded(child: SurvivorPanel()),

                          SizedBox(width: 20),

                          Expanded(child: AlertsPanel()),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    const MissionStatistics(),

                    SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
