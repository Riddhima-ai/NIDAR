// lib/widgets/notifications_panel.dart
import 'package:flutter/material.dart';
import 'package:nidar/state/mission_state.dart';
import 'package:nidar/theme/app_theme.dart';

class NotificationsPanel extends StatelessWidget {
  final MissionState mission;
  const NotificationsPanel({super.key, required this.mission});

  Color _colorFor(String msg, AppPalette p) {
    if (msg.contains('ABORT')) return p.danger;
    if (msg.contains('Survivor')) return p.warning;
    if (msg.contains('complete') || msg.contains('started')) return p.success;
    return p.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('NOTIFICATIONS',
                    style: TextStyle(
                        color: p.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                        letterSpacing: 0.3)),
                const Spacer(),
                TextButton(
                  onPressed: mission.notifications.isEmpty
                      ? null
                      : mission.clearNotifications,
                  child: const Text('Clear All', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            Expanded(
              child: mission.notifications.isEmpty
                  ? Center(
                      child: Text('No notifications',
                          style: TextStyle(color: p.textSecondary, fontSize: 12.5)),
                    )
                  : ListView.builder(
                      itemCount: mission.notifications.length,
                      itemBuilder: (context, i) {
                        final n = mission.notifications[i];
                        final color = _colorFor(n, p);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Container(
                                  width: 7, height: 7,
                                  decoration: BoxDecoration(
                                      color: color, shape: BoxShape.circle),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(n,
                                    style:
                                        TextStyle(color: p.textPrimary, fontSize: 12.5)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}