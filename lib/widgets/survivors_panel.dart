// lib/widgets/survivors_panel.dart
import 'package:flutter/material.dart';
import 'package:nidar/state/mission_state.dart';
import 'package:nidar/theme/app_theme.dart';

class SurvivorsPanel extends StatelessWidget {
  final MissionState mission;
  const SurvivorsPanel({super.key, required this.mission});

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
              'SURVIVORS DETECTED (${mission.survivors.length}/${mission.survivorsTotal})',
              style: TextStyle(
                  color: p.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                  letterSpacing: 0.3),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: mission.survivors.isEmpty
                  ? Center(
                      child: Text('No survivors detected yet',
                          style: TextStyle(color: p.textSecondary, fontSize: 12.5)),
                    )
                  : ListView.separated(
                      itemCount: mission.survivors.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final s = mission.survivors[mission.survivors.length - 1 - i];
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: p.surface2,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: p.border),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: p.dangerMuted,
                                child: Icon(Icons.person, size: 15, color: p.danger),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Survivor ${s.id}',
                                        style: TextStyle(
                                            color: p.textPrimary,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600)),
                                    Text('Grid ${s.grid} · ${s.detectedAt}',
                                        style: TextStyle(
                                            color: p.textSecondary, fontSize: 11.5)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: p.successMuted,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('${s.confidence}%',
                                    style: TextStyle(
                                        color: p.success,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700)),
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