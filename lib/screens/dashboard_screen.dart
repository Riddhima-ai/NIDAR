// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:nidar/state/mission_state.dart';
import 'package:nidar/theme/app_theme.dart';
import 'package:nidar/widgets/camera_feed_panel.dart';
import 'package:nidar/widgets/camera_fullscreen_view.dart';
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
  bool cameraCollapsed = false; // <-- must exist

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
                  child: SingleChildScrollView(
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
        return SizedBox(height: 700, child: LiveMapGrid(mission: mission));
      case NavSection.survivors:
        return SizedBox(height: 700, child: SurvivorsPanel(mission: mission));
      case NavSection.telemetry:
        return SizedBox(height: 700, child: TelemetryCard(mission: mission));
      case NavSection.mission:
        return SizedBox(
          height: 700,
          child: Column(
            children: [
              SizedBox(height: 300, child: MissionTimelinePanel(mission: mission)),
              const SizedBox(height: 16),
              Expanded(child: MissionControlsPanel(mission: mission)),
            ],
          ),
        );
      case NavSection.camera:
  return SizedBox(
    height: 700,
    child: CameraFullscreenView(
      mission: mission,
      onExitFullscreen: () {
        setState(() {
          selected = NavSection.dashboard;
        });
      },
    ),
  );
      case NavSection.logs:
        return SizedBox(height: 700, child: NotificationsPanel(mission: mission));
    }
  }

  Widget _dashboardBody() {
    const rowSpacing = 16.0;
    
    final cameraHeight = cameraCollapsed ? 56.0 : 380.0;
    final survivorsHeight = cameraCollapsed ? 624.0 : 300.0;
    final topRowHeight = cameraHeight + rowSpacing + survivorsHeight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: topRowHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 320,
                child: Column(
                  children: [
                    Expanded(child: TelemetryCard(mission: mission)),
                    const SizedBox(height: 16),
                    Expanded(child: MissionProgress(mission: mission)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: LiveMapGrid(mission: mission)),
              const SizedBox(width: 16),
              SizedBox(
                width: 420,
                child: Column(
                  children: [
                    // Animated so the collapse/expand isn't an instant snap.
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                      height: cameraHeight,
                      child: CameraFeedPanel(
                        mission: mission,
                        collapsed: cameraCollapsed,
                        onToggleCollapse: () =>
                            setState(() => cameraCollapsed = !cameraCollapsed),
                        onExpand: () => setState(() => selected = NavSection.camera),
                      ),
                    ),
                    const SizedBox(height: rowSpacing),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                      height: survivorsHeight,
                      child: SurvivorsPanel(mission: mission),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
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
        const SizedBox(height: 16),
      ],
    );
  }
}