// lib/widgets/footer_status_bar.dart
import 'package:flutter/material.dart';
import 'package:nidar/state/mission_state.dart';
import 'package:nidar/theme/app_theme.dart';

class FooterStatusBar extends StatelessWidget {
  final MissionState mission;
  const FooterStatusBar({super.key, required this.mission});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final distance = (mission.elapsed.inSeconds * 0.25).toStringAsFixed(1);
    return Container(
      color: p.surface,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          _item(p, Icons.flight, 'Drone ID', 'NIDAR-01'),
          _sep(p),
          _item(p, Icons.smart_toy_outlined, 'Pilot Mode', 'Autonomous'),
          _sep(p),
          _item(p, Icons.timer_outlined, 'Max Flight Time', '30:00'),
          _sep(p),
          _item(p, Icons.route, 'Distance Travelled', '$distance m'),
          _sep(p),
          _item(p, Icons.meeting_room_outlined, 'Rooms Explored',
              '${mission.survivors.length + 4} / 12'),
          _sep(p),
          _item(p, Icons.map_outlined, 'Map Accuracy', '98%'),
          _sep(p),
          _item(p, Icons.gps_fixed, 'Localisation', 'Stable'),
          const Spacer(),
          Icon(Icons.wifi, size: 16, color: p.success),
          const SizedBox(width: 6),
          Text('Connection: Strong',
              style: TextStyle(color: p.success, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _sep(AppPalette p) => Container(
      width: 1, height: 24, color: p.border, margin: const EdgeInsets.symmetric(horizontal: 18));

  Widget _item(AppPalette p, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 15, color: p.textSecondary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: p.textSecondary, fontSize: 10.5)),
            Text(value,
                style: TextStyle(
                    color: p.textPrimary, fontSize: 12.5, fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }
}