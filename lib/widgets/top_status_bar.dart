// lib/widgets/top_status_bar.dart
import 'package:flutter/material.dart';
import 'package:nidar/state/mission_state.dart';
import 'package:nidar/theme/app_theme.dart';

class TopStatusBar extends StatelessWidget {
  final MissionState mission;
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  const TopStatusBar({
    super.key,
    required this.mission,
    required this.themeMode,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final phaseLabel = switch (mission.phase) {
      MissionPhase.idle => 'STANDBY',
      MissionPhase.active => 'MISSION ACTIVE',
      MissionPhase.paused => 'MISSION PAUSED',
      MissionPhase.returning => 'RETURNING',
      MissionPhase.aborted => 'ABORTED',
      MissionPhase.completed => 'COMPLETE',
    };
    final phaseColor = switch (mission.phase) {
      MissionPhase.idle => p.textSecondary,
      MissionPhase.active => p.success,
      MissionPhase.paused => p.warning,
      MissionPhase.returning => p.accent,
      MissionPhase.aborted => p.danger,
      MissionPhase.completed => p.success,
    };

    return Container(
      color: p.surface,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: [
          _statusPill(phaseLabel, phaseColor),
          const SizedBox(width: 28),
          _stat('Time Elapsed', _fmt(mission.elapsed), p),
          const SizedBox(width: 28),
          _statWithBar('Exploration',
              '${(mission.explorationPercent * 100).toStringAsFixed(0)}%',
              mission.explorationPercent, p.accent, p),
          const SizedBox(width: 28),
          _stat('Survivors Found',
              '${mission.survivors.length} / ${mission.survivorsTotal}', p,
              icon: Icons.person),
          const SizedBox(width: 28),
          _statWithBar('Battery', '${mission.battery}%', mission.battery / 100,
              mission.battery < 25 ? p.danger : p.success, p),
          const Spacer(),
          _chip(Icons.wifi_tethering, 'Telemetry', 'Excellent', p.success, p),
          const SizedBox(width: 10),
          _chip(Icons.videocam_outlined, 'Video', 'Good', p.success, p),
          const SizedBox(width: 10),
          _chip(Icons.blur_on, 'SLAM', 'Running', p.accent, p),
          const SizedBox(width: 10),
          _chip(Icons.satellite_alt_outlined, 'GPS', 'Denied', p.danger, p),
          const SizedBox(width: 16),
          IconButton(
            onPressed: onToggleTheme,
            icon: Icon(
              themeMode == ThemeMode.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              color: p.textSecondary,
            ),
          ),
          CircleAvatar(
            radius: 16,
            backgroundColor: p.accentMuted,
            child: Icon(Icons.person, size: 18, color: p.accent),
          ),
        ],
      ),
    );
  }

  Widget _statusPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12.5)),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, AppPalette p, {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: p.textSecondary, fontSize: 11.5)),
        const SizedBox(height: 3),
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: p.textPrimary),
              const SizedBox(width: 4),
            ],
            Text(value,
                style: TextStyle(
                    color: p.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
          ],
        ),
      ],
    );
  }

  Widget _statWithBar(
      String label, String value, double progress, Color barColor, AppPalette p) {
    return SizedBox(
      width: 90,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: p.textSecondary, fontSize: 11.5)),
          const SizedBox(height: 3),
          Text(value,
              style: TextStyle(
                  color: p.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: p.border,
              valueColor: AlwaysStoppedAnimation(barColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label, String value, Color color, AppPalette p) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: p.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: p.textSecondary, fontSize: 11)),
          const SizedBox(width: 5),
          Text(value,
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}