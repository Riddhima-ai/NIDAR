import 'package:flutter/material.dart';
import 'package:nidar/theme/app_theme.dart';

enum NavSection { dashboard, map, survivors, telemetry, mission, camera, logs }

class SidebarNav extends StatelessWidget {
  final NavSection selected;
  final ValueChanged<NavSection> onSelect;
  final VoidCallback onEmergency;

  const SidebarNav({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.onEmergency,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: 220,
      color: p.sidebar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Row(
              children: [
                Icon(Icons.flight, color: p.accent, size: 26),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('NIDAR',
                        style: TextStyle(
                            color: p.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                    Text('AirMouse GCS',
                        style: TextStyle(color: p.textSecondary, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          _item(context, NavSection.dashboard, Icons.dashboard_outlined, 'Dashboard'),
          _item(context, NavSection.map, Icons.map_outlined, 'Map'),
          _item(context, NavSection.survivors, Icons.groups_outlined, 'Survivors'),
          _item(context, NavSection.telemetry, Icons.speed_outlined, 'Telemetry'),
          _item(context, NavSection.mission, Icons.radar, 'Mission'),
          _item(context, NavSection.camera, Icons.videocam_outlined, 'Camera'),
          _item(context, NavSection.logs, Icons.receipt_long_outlined, 'Logs'),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onEmergency,
                icon: Icon(Icons.warning_amber_rounded, color: p.danger, size: 18),
                label: Text('EMERGENCY',
                    style: TextStyle(color: p.danger, fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: p.danger.withOpacity(0.5)),
                  backgroundColor: p.dangerMuted,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, NavSection section, IconData icon, String label) {
    final p = context.palette;
    final isSelected = selected == section;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: isSelected ? p.accentMuted : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => onSelect(section),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 19, color: isSelected ? p.accent : p.textSecondary),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? p.accent : p.textSecondary,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}