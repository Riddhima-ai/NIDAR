import 'package:flutter/material.dart';
import 'package:nidar/theme/app_theme.dart';
import 'package:nidar/screens/dashboard_screen.dart';
import 'package:nidar/widgets/design_scale.dart';

void main() => runApp(const NidarApp());

class NidarApp extends StatefulWidget {
  const NidarApp({super.key});

  @override
  State<NidarApp> createState() => _NidarAppState();
}

class _NidarAppState extends State<NidarApp> {
  ThemeMode _mode = ThemeMode.dark;

  void _toggleTheme() =>
      setState(() => _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NIDAR GCS',
      debugShowCheckedModeBanner: false,
      themeMode: _mode,
      theme: lightAppTheme,
      darkTheme: darkAppTheme,
      home: DesignScale(
        designWidth:  1600,
        designHeight: 900,
        child: DashboardScreen(onToggleTheme: _toggleTheme, themeMode: _mode),
      ),
    );
  }
}