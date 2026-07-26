// lib/widgets/camera_feed_panel.dart
import 'package:flutter/material.dart';
import 'package:nidar/state/mission_state.dart';
import 'package:nidar/theme/app_theme.dart';

class CameraFeedPanel extends StatefulWidget {
  final MissionState mission;
  const CameraFeedPanel({super.key, required this.mission});

  @override
  State<CameraFeedPanel> createState() => _CameraFeedPanelState();
}

class _CameraFeedPanelState extends State<CameraFeedPanel> {
  bool muted = false;
  bool recording = true;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final live = widget.mission.phase == MissionPhase.active ||
        widget.mission.phase == MissionPhase.returning;
    final detected = widget.mission.survivors.isNotEmpty && live;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('LIVE CAMERA FEED',
                    style: TextStyle(
                        color: p.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                        letterSpacing: 0.5)),
                const Spacer(),
                Container(
                  width: 7, height: 7,
                  decoration: BoxDecoration(
                      color: live ? p.danger : p.textSecondary, shape: BoxShape.circle),
                ),
                const SizedBox(width: 5),
                Text(live ? 'LIVE' : 'IDLE',
                    style: TextStyle(
                        color: live ? p.danger : p.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  color: Colors.black,
                  child: Stack(
                    children: [
                      if (!live)
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.videocam_off_outlined,
                                  color: p.textSecondary, size: 32),
                              const SizedBox(height: 8),
                              Text('Waiting for camera stream…',
                                  style: TextStyle(color: p.textSecondary, fontSize: 12)),
                            ],
                          ),
                        )
                      else
                        Center(
                          child: Icon(Icons.image_outlined,
                              color: Colors.white24, size: 40),
                        ),
                      if (detected)
                        Positioned(
                          left: 40,
                          top: 30,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                color: p.success,
                                child: Text(
                                    'HUMAN ${widget.mission.survivors.last.confidence}%',
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700)),
                              ),
                              Container(
                                width: 90, height: 110,
                                decoration: BoxDecoration(
                                  border: Border.all(color: p.success, width: 2),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _iconBtn(p, Icons.camera_alt_outlined, false, () {}),
                _iconBtn(p, recording ? Icons.videocam : Icons.videocam_off,
                    recording, () => setState(() => recording = !recording)),
                _iconBtn(p, muted ? Icons.mic_off : Icons.mic, muted,
                    () => setState(() => muted = !muted)),
                _iconBtn(p, Icons.volume_up_outlined, false, () {}),
                _iconBtn(p, Icons.fullscreen, false, () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn(AppPalette p, IconData icon, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: active ? p.accentMuted : p.surface2,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: active ? p.accent : p.textSecondary),
      ),
    );
  }
}