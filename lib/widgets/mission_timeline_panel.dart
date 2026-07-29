import 'package:flutter/material.dart';
import 'package:nidar/state/mission_state.dart';
import 'package:nidar/theme/app_theme.dart';

class MissionTimelinePanel extends StatelessWidget {
  final MissionState mission;

  const MissionTimelinePanel({
    super.key,
    required this.mission,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    const double nodeSize = 30;
    const double spacing = 120;

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
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: mission.timeline.length * spacing,
                  child: Stack(
                    children: [

                      /// GREY BACKGROUND LINE
                      Positioned(
                        top: nodeSize / 2,
                        left: nodeSize,
                        right: nodeSize,
                        child: Container(
                          height: 2,
                          color: p.border,
                        ),
                      ),

                      /// GREEN COMPLETED CONNECTORS
                      ...List.generate(
                        mission.timeline.length - 1,
                        (i) {
                          if (!mission.timeline[i].done) {
                            return const SizedBox();
                          }

                          return Positioned(
                            top: nodeSize / 2,
                            left: spacing * i + nodeSize,
                            child: Container(
                              width: spacing - nodeSize,
                              height: 2,
                              color: p.success,
                            ),
                          );
                        },
                      ),

                      /// TIMELINE NODES
                      ...List.generate(
                        mission.timeline.length,
                        (i) {
                          final e = mission.timeline[i];

                          final color =
                              e.done ? p.success : p.textSecondary;

                          return Positioned(
                            left: spacing * i,
                            child: SizedBox(
                              width: spacing,
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [

                                  /// Bubble
                                  Container(
                                    width: nodeSize,
                                    height: nodeSize,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: e.done
                                          ? color.withOpacity(.15)
                                          : p.surface2,
                                      border: Border.all(
                                        color: color,
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      e.done
                                          ? Icons.check
                                          : Icons.circle_outlined,
                                      size: 16,
                                      color: color,
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  SizedBox(
                                    width: nodeSize,
                                    child: Text(
                                      e.label,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: p.textPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 3),

                                  SizedBox(
                                    width: nodeSize,
                                    child: Text(
                                      e.time,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: p.textSecondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}