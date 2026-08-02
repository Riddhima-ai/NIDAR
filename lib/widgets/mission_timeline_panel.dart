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
    // Widened so labels like "Survivor #1 Found" wrap by word, not letter.
    const double spacing = 140;

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
                      /// Runs between the centers of the first and last
                      /// nodes now that each node is centered in its
                      /// own `spacing`-wide column.
                      Positioned(
                        top: nodeSize / 2,
                        left: spacing / 2,
                        right: spacing / 2,
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
                            left: spacing * i + spacing / 2 + nodeSize / 2,
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
                                // Center everything under this node so the
                                // bubble, label, and time all line up.
                                crossAxisAlignment:
                                    CrossAxisAlignment.center,
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

                                  // Wider box + generous padding so text
                                  // wraps by whole word ("Survivor #1"
                                  // on one line, "Found" on the next)
                                  // instead of one letter per line.
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 6),
                                    child: Text(
                                      e.label,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: p.textPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        height: 1.25,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 3),

                                  Text(
                                    e.time,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: p.textSecondary,
                                      fontSize: 11,
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