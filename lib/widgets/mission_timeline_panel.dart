import 'package:flutter/material.dart';
import 'package:nidar/state/mission_state.dart';
import 'package:nidar/theme/app_theme.dart';

class MissionTimelinePanel extends StatelessWidget {
  final MissionState mission;
  const MissionTimelinePanel({super.key, required this.mission});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MISSION TIMELINE',
              style: TextStyle(
                color: p.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: mission.timeline.length,
                separatorBuilder: (_, __) => Container(
                  width: 32,
                  height: 2,
                  margin: const EdgeInsets.only(top: 18),
                  color: p.border,
                ),
                itemBuilder: (context, i) {
                  final e = mission.timeline[i];
                  final isLast = i == mission.timeline.length - 1;
                  final color =
                      e.done ? (isLast ? p.accent : p.success) : p.textSecondary;
                  return SizedBox(
                    width: 96,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: e.done ? color.withOpacity(0.15) : p.surface2,
                            border: Border.all(color: color, width: 1.6),
                          ),
                          child: Icon(
                            e.done ? Icons.check : Icons.circle_outlined,
                            size: 16,
                            color: color,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Fixed 2-line-tall label area so text never overflows
                        // regardless of whether the label wraps to 1 or 2 lines.
                        SizedBox(
                          height: 30,
                          child: Text(
                            e.label,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: p.textPrimary,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          e.time,
                          style: TextStyle(color: p.textSecondary, fontSize: 10),
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