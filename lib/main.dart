import 'package:flutter/material.dart';
import 'package:nidar/screens/dashboard_screen.dart';
import 'package:nidar/services/mock_data.dart';
import 'package:nidar/widgets/telemetry_card.dart';

void main(){
  runApp(const NidarApp());
}

class NidarApp extends StatelessWidget {
  const NidarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DashboardScreen(),
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
    );
  }
}