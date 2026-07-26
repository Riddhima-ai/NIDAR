import 'package:flutter/material.dart';
import 'package:nidar/state/mission_state.dart';
import 'package:nidar/theme/app_theme.dart';

class MissionProgress extends StatelessWidget {
  final MissionState mission;
  const MissionProgress({super.key, required this.mission});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final pct = mission.explorationPercent;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MISSION PROGRESS',
              style: TextStyle(
                color: p.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: SizedBox(
                width: 130,
                height: 130,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 130,
                      height: 130,
                      child: CircularProgressIndicator(
                        value: pct,
                        strokeWidth: 10,
                        backgroundColor: p.border,
                        valueColor: AlwaysStoppedAnimation(p.success),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(pct * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: p.textPrimary,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Explored',
                          style: TextStyle(color: p.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 6),

            // Legend rows scroll internally instead of overflowing.
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _legendRow(
                      p,
                      p.success,
                      'Explored Area',
                      '${(pct * 100).toStringAsFixed(0)}%',
                    ),
                    _legendRow(
                      p,
                      p.border,
                      'Unexplored Area',
                      '${(100 - pct * 100).toStringAsFixed(0)}%',
                    ),
                    _legendRow(p, p.textSecondary, 'Total Area', '15m x 15m'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendRow(AppPalette p, Color dot, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: dot,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(color: p.textSecondary, fontSize: 13)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: p.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}