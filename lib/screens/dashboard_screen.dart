// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:nidar/state/mission_state.dart';
import 'package:nidar/theme/app_theme.dart';
import 'package:nidar/widgets/camera_feed_panel.dart';
import 'package:nidar/widgets/footer_status_bar.dart';
import 'package:nidar/widgets/live_map_grid.dart';
import 'package:nidar/widgets/mission_controls_panel.dart';
import 'package:nidar/widgets/mission_progress_card.dart';
import 'package:nidar/widgets/mission_timeline_panel.dart';
import 'package:nidar/widgets/notifications_panel.dart';
import 'package:nidar/widgets/sidebar_nav.dart';
import 'package:nidar/widgets/survivors_panel.dart';
import 'package:nidar/widgets/telemetry_card.dart';
import 'package:nidar/widgets/top_status_bar.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;

  const DashboardScreen({
    super.key,
    required this.onToggleTheme,
    required this.themeMode,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final MissionState mission = MissionState();
  NavSection selected = NavSection.dashboard;

  @override
  void initState() {
    super.initState();
    mission.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    mission.dispose();
    super.dispose();
  }

  void _emergency() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Emergency Abort'),
        content: const Text('Immediately halt the mission and trigger recall/RTB?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              mission.abort();
              Navigator.pop(ctx);
            },
            child: const Text('Confirm Abort'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.bg,
      body: Row(
        children: [
          SidebarNav(
            selected: selected,
            onSelect: (s) => setState(() => selected = s),
            onEmergency: _emergency,
          ),
          Expanded(
            child: Column(
              children: [
                TopStatusBar(
                  mission: mission,
                  themeMode: widget.themeMode,
                  onToggleTheme: widget.onToggleTheme,
                ),
                Container(height: 1, color: p.border),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildBody(),
                  ),
                ),
                FooterStatusBar(mission: mission),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (selected) {
      case NavSection.dashboard:
        return _dashboardBody();
      case NavSection.map:
        return LiveMapGrid(mission: mission);
      case NavSection.survivors:
        return SurvivorsPanel(mission: mission);
      case NavSection.telemetry:
        return TelemetryCard(mission: mission);
      case NavSection.mission:
        return Column(
          children: [
            // Fixed height so timeline nodes with 2-line labels
            // (e.g. "Survivor #1 Found") never overflow.
            SizedBox(height: 160, child: MissionTimelinePanel(mission: mission)),
            const SizedBox(height: 16),
            Expanded(child: MissionControlsPanel(mission: mission)),
          ],
        );
      case NavSection.logs:
        return NotificationsPanel(mission: mission);
    }
  }

  Widget _dashboardBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          // Was flex: 3 — bumped so the map/camera row gets more room
          // relative to the bottom row.
          flex: 4,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 260,
                child: Column(
                  children: [
                    Expanded(child: TelemetryCard(mission: mission)),
                    const SizedBox(height: 16),
                    Expanded(child: MissionProgress(mission: mission)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(flex: 3, child: LiveMapGrid(mission: mission)),
              const SizedBox(width: 16),
              // Camera feed is now the dominant panel on the right:
              // wider (340 vs old 300) and takes 3/5 of the vertical
              // space instead of splitting 50/50 with Survivors.
              SizedBox(
                width: 340,
                child: Column(
                  children: [
                    Expanded(flex: 3, child: CameraFeedPanel(mission: mission)),
                    const SizedBox(height: 16),
                    Expanded(flex: 2, child: SurvivorsPanel(mission: mission)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          // Was 190 — bumped so Mission Controls has enough room for
          // 3 buttons + divider + failsafe row without overflowing.
          height: 260,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 2, child: MissionTimelinePanel(mission: mission)),
              const SizedBox(width: 16),
              Expanded(child: MissionControlsPanel(mission: mission)),
              const SizedBox(width: 16),
              Expanded(child: NotificationsPanel(mission: mission)),
            ],
          ),
        ),
      ],
    );
  }
}