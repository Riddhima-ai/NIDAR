import 'package:flutter/material.dart';
import 'package:nidar/state/mission_state.dart';
import 'package:nidar/theme/app_theme.dart';

class TelemetryCard extends StatelessWidget {
  final MissionState mission;
  const TelemetryCard({super.key, required this.mission});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'TELEMETRY',
                  style: TextStyle(
                    color: p.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Icon(Icons.signal_cellular_alt, size: 16, color: p.textSecondary),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 6),

            // Everything below scrolls internally instead of overflowing
            // when the parent gives this card a fixed height.
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _row(
                      p,
                      Icons.battery_full,
                      'Battery',
                      '${mission.battery} %',
                      mission.battery < 25 ? p.danger : p.success,
                    ),
                    _row(
                      p,
                      Icons.height,
                      'Altitude',
                      '${mission.altitude.toStringAsFixed(1)} m',
                      p.textPrimary,
                    ),
                    _row(
                      p,
                      Icons.speed,
                      'Speed',
                      '${mission.speed.toStringAsFixed(1)} m/s',
                      p.textPrimary,
                    ),
                    _row(
                      p,
                      Icons.smart_toy_outlined,
                      'Flight Mode',
                      'AUTO',
                      p.accent,
                    ),
                    _row(
                      p,
                      Icons.wifi_tethering,
                      'Signal Strength',
                      '${mission.signalDbm.toStringAsFixed(0)} dBm',
                      p.textPrimary,
                    ),
                    _row(
                      p,
                      Icons.satellite_alt_outlined,
                      'Satellites',
                      '0 (GPS Denied)',
                      p.danger,
                    ),
                    _row(
                      p,
                      Icons.thermostat,
                      'Temperature',
                      '${mission.tempC.toStringAsFixed(0)} °C',
                      p.textPrimary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(
    AppPalette p,
    IconData icon,
    String label,
    String value,
    Color valueColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 17, color: p.textSecondary),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(color: p.textSecondary, fontSize: 13.5)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}