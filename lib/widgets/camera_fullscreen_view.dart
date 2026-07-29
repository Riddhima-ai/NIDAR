import 'package:flutter/material.dart';
import 'package:nidar/screens/dashboard_screen.dart';
import 'package:nidar/state/mission_state.dart';
import 'package:nidar/theme/app_theme.dart';


class CameraFullscreenView extends StatefulWidget {
  final MissionState mission;
  
  final VoidCallback onExitFullscreen;

  const CameraFullscreenView({super.key, required this.mission,
  
    required this.onExitFullscreen,});

  @override
  State<CameraFullscreenView> createState() => _CameraFullscreenViewState();
}

class _CameraFullscreenViewState extends State<CameraFullscreenView> {
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('LIVE CAMERA FEED',
                    style: TextStyle(
                        color: p.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        letterSpacing: 0.5)),
                const Spacer(),
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                      color: live ? p.danger : p.textSecondary, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(live ? 'LIVE' : 'IDLE',
                    style: TextStyle(
                        color: live ? p.danger : p.textSecondary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
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
                                  color: p.textSecondary, size: 48),
                              const SizedBox(height: 12),
                              Text('Waiting for camera stream…',
                                  style: TextStyle(color: p.textSecondary, fontSize: 14)),
                            ],
                          ),
                        )
                      else
                        Center(
                          child: Icon(Icons.image_outlined,
                              color: Colors.white24, size: 64),
                        ),
                      if (detected)
                        Positioned(
                          left: 60,
                          top: 50,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                color: p.success,
                                child: Text(
                                    'HUMAN ${widget.mission.survivors.last.confidence}%',
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700)),
                              ),
                              Container(
                                width: 140, height: 170,
                                decoration: BoxDecoration(
                                  border: Border.all(color: p.success, width: 2.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'NIDAR-01 · Front Cam',
                            style: TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _iconBtn(
  p,
  Icons.fullscreen_exit,
  false,
  widget.onExitFullscreen,
),
                const SizedBox(width: 14),
                
                
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
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: active ? p.accentMuted : p.surface2,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: active ? p.accent : p.textSecondary),
      ),
    );
  }
}