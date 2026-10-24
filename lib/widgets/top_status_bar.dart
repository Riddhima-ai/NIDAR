
import 'package:flutter/material.dart';
import 'package:nidar/state/mission_state.dart';
import 'package:nidar/theme/app_theme.dart';

class TopStatusBar extends StatelessWidget {
  final MissionState mission;
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  const TopStatusBar({
    super.key,
    required this.mission,
    required this.themeMode,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    final phaseLabel = switch (mission.phase) {
      MissionPhase.idle => 'STANDBY',
      MissionPhase.active => 'MISSION ACTIVE',
      MissionPhase.paused => 'MISSION PAUSED',
      MissionPhase.returning => 'RETURNING',
      MissionPhase.aborted => 'ABORTED',
      MissionPhase.completed => 'SUCCESS',
      MissionPhase.failed => 'FAILURE',
    };

    final phaseColor = switch (mission.phase) {
      MissionPhase.idle => p.textSecondary,
      MissionPhase.active => p.success,
      MissionPhase.paused => p.warning,
      MissionPhase.returning => p.accent,
      MissionPhase.aborted => p.danger,
      MissionPhase.completed => p.success,
      MissionPhase.failed => p.danger,
    };

    final outcomeLabel = switch (mission.phase) {
      MissionPhase.completed => 'OUTCOME: SUCCESS',
      MissionPhase.aborted => 'OUTCOME: ABORTED',
      MissionPhase.failed => 'OUTCOME: FAILURE',
      MissionPhase.idle => 'OUTCOME: NOT STARTED',
      _ => 'OUTCOME: IN PROGRESS',
    };

    final outcomeColor = switch (mission.phase) {
      MissionPhase.completed => p.success,
      MissionPhase.aborted => p.danger,
      MissionPhase.failed => p.danger,
      MissionPhase.idle => p.textSecondary,
      _ => p.accent,
    };

    final batteryColor = mission.battery <= 15
        ? p.danger
        : mission.battery <= 25
            ? p.warning
            : p.success;

    final batteryWarning = mission.battery <= 15
        ? 'CRITICAL BATTERY'
        : mission.battery <= 25
            ? 'LOW BATTERY'
            : 'Battery healthy';

    return Container(
      width: double.infinity,
      color: p.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // STATUS ROW
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _statusPill(
                mission.connected ? 'CONNECTED' : 'DISCONNECTED',
                mission.connected ? p.success : p.danger,
                p,
              ),
              _statusPill(
                mission.armed ? 'ARMED' : 'DISARMED',
                mission.armed ? p.warning : p.textSecondary,
                p,
              ),
              _statusPill(
                'MODE: ${mission.flightMode}',
                p.accent,
                p,
              ),
              _statusPill(
                'MISSION: $phaseLabel',
                phaseColor,
                p,
              ),
              _statusPill(
                outcomeLabel,
                outcomeColor,
                p,
              ),
              IconButton(
                tooltip: 'Toggle theme',
                onPressed: onToggleTheme,
                icon: Icon(
                  themeMode == ThemeMode.dark
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                  color: p.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Divider(height: 1, color: p.border),
          const SizedBox(height: 12),

          // LIVE METRICS
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth < 520
                  ? 2
                  : constraints.maxWidth < 850
                      ? 3
                      : constraints.maxWidth < 1150
                          ? 4
                          : 7;

              return Wrap(
                spacing: 0,
                runSpacing: 14,
                children: [
                  _metricCell(
                    columns: columns,
                    availableWidth: constraints.maxWidth,
                    label: 'BATTERY',
                    value: '${mission.battery}%',
                    detail: batteryWarning,
                    color: batteryColor,
                    p: p,
                    progress: (mission.battery / 100)
                        .clamp(0.0, 1.0),
                  ),
                  _metricCell(
                    columns: columns,
                    availableWidth: constraints.maxWidth,
                    label: 'POSITION X / Y',
                    value:
                        '${mission.droneX.toStringAsFixed(1)} / '
                        '${mission.droneY.toStringAsFixed(1)} m',
                    detail: 'Horizontal position',
                    color: p.textPrimary,
                    p: p,
                  ),
                  _metricCell(
                    columns: columns,
                    availableWidth: constraints.maxWidth,
                    label: 'ALTITUDE / Z',
                    value:
                        '${mission.droneZ.toStringAsFixed(1)} m',
                    detail: 'Vertical position',
                    color: p.textPrimary,
                    p: p,
                  ),
                  _metricCell(
                    columns: columns,
                    availableWidth: constraints.maxWidth,
                    label: 'MISSION STAGE',
                    value: mission.missionStage,
                    detail: 'Current backend stage',
                    color: phaseColor,
                    p: p,
                  ),
                  _metricCell(
                    columns: columns,
                    availableWidth: constraints.maxWidth,
                    label: 'EXPLORATION',
                    value:
                        '${(mission.explorationPercent * 100).toStringAsFixed(1)}%',
                    detail: 'Area explored',
                    color: p.accent,
                    p: p,
                    progress: mission.explorationPercent
                        .clamp(0.0, 1.0),
                  ),
                  _metricCell(
                    columns: columns,
                    availableWidth: constraints.maxWidth,
                    label: 'TIME ELAPSED',
                    value: _fmt(mission.elapsed),
                    detail: 'Mission duration',
                    color: p.textPrimary,
                    p: p,
                  ),
                  _metricCell(
                    columns: columns,
                    availableWidth: constraints.maxWidth,
                    label: 'SURVIVORS',
                    value:
                        '${mission.survivors.length} / ${mission.survivorsTotal}',
                    detail: 'Detected',
                    color: p.textPrimary,
                    p: p,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _statusPill(
    String label,
    Color color,
    AppPalette p,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCell({
    required int columns,
    required double availableWidth,
    required String label,
    required String value,
    required String detail,
    required Color color,
    required AppPalette p,
    double? progress,
  }) {
    final cellWidth = availableWidth / columns;

    return SizedBox(
      width: cellWidth,
      child: Padding(
        padding: const EdgeInsets.only(
          right: 12,
          left: 2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: p.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              detail,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color == p.danger || color == p.warning
                    ? color
                    : p.textSecondary,
                fontSize: 10,
              ),
            ),
            if (progress != null) ...[
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: p.border,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final s = d.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    return '$m:$s';
  }
}
