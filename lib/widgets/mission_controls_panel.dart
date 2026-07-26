// lib/widgets/mission_controls_panel.dart
import 'package:flutter/material.dart';
import 'package:nidar/state/mission_state.dart';
import 'package:nidar/theme/app_theme.dart';

class MissionControlsPanel extends StatelessWidget {
  final MissionState mission;
  const MissionControlsPanel({super.key, required this.mission});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final canPause = mission.phase == MissionPhase.active || mission.phase == MissionPhase.paused;
    final canReturn = mission.phase == MissionPhase.active || mission.phase == MissionPhase.paused;
    final canAbort = canReturn || mission.phase == MissionPhase.returning;
    final failsafeOk = mission.phase != MissionPhase.aborted;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('MISSION CONTROLS',
                style: TextStyle(
                    color: p.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                    letterSpacing: 0.3)),
            const SizedBox(height: 14),

            if (mission.phase == MissionPhase.idle) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: mission.armed ? mission.startMission : null,
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: const Text('Start Mission'),
                  style: _style(p, p.success),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: mission.armed ? mission.disarm : mission.arm,
                  icon: Icon(mission.armed ? Icons.lock_open : Icons.lock, size: 18),
                  label: Text(mission.armed ? 'Disarm' : 'Arm'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: p.textPrimary,
                    side: BorderSide(color: p.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: canPause ? mission.togglePause : null,
                  icon: Icon(
                      mission.phase == MissionPhase.paused ? Icons.play_arrow : Icons.pause,
                      size: 18),
                  label: Text(mission.phase == MissionPhase.paused ? 'RESUME' : 'PAUSE'),
                  style: _style(p, p.success),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: canReturn ? mission.returnToBase : null,
                  icon: const Icon(Icons.u_turn_left, size: 18),
                  label: const Text('RETURN TO BASE'),
                  style: _style(p, p.warning),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: canAbort ? () => _confirmAbort(context, mission) : null,
                  icon: const Icon(Icons.stop, size: 18),
                  label: const Text('ABORT MISSION'),
                  style: _style(p, p.danger),
                ),
              ),
            ],

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('Failsafe Status',
                    style: TextStyle(color: p.textSecondary, fontSize: 12.5)),
                const SizedBox(width: 10),
                Icon(failsafeOk ? Icons.check_circle : Icons.error,
                    size: 15, color: failsafeOk ? p.success : p.danger),
                const SizedBox(width: 4),
                Text(failsafeOk ? 'OK' : 'FAULT',
                    style: TextStyle(
                        color: failsafeOk ? p.success : p.danger,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    failsafeOk
                        ? 'The mission is running normally.'
                        : 'Mission aborted — check drone status.',
                    style: TextStyle(color: p.textSecondary, fontSize: 11.5),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmAbort(BuildContext context, MissionState mission) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Abort mission?'),
        content: const Text(
            'This will immediately stop autonomous navigation and log the abort event. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              mission.abort();
              Navigator.pop(ctx);
            },
            child: const Text('Abort'),
          ),
        ],
      ),
    );
  }

  ButtonStyle _style(AppPalette p, Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      disabledBackgroundColor: p.surface2,
      disabledForegroundColor: p.textSecondary,
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
