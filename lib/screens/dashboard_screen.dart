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
  bool cameraCollapsed = false;
  void onExitFullscreen() {
  setState(() {
    selected = NavSection.dashboard;
  });
}

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
          
          LayoutBuilder(
            builder: (context, constraints) {
              return SidebarNav(
                selected: selected,
                onSelect: (s) => setState(() => selected = s),
                onEmergency: _emergency,
              );
            },
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
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return _buildBody(constraints.maxWidth);
                      },
                    ),
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

  Widget _buildBody(double availableWidth) {
    switch (selected) {
      case NavSection.dashboard:
        return _dashboardBody(availableWidth);
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
              SizedBox(height: 300, child:MissionTimelinePanel(mission: mission)) ,
              const SizedBox(height: 16),
              Expanded(child: MissionControlsPanel(mission: mission)),
            ],
          ),
        );
      case NavSection.camera:
        return SizedBox(height: 700, child:CameraFullscreenView(mission: mission,onExitFullscreen: onExitFullscreen,)) ;
      case NavSection.logs:
        return SizedBox(height: 700, child: NotificationsPanel(mission: mission));
    }
  }

  Widget _dashboardBody(double availableWidth) {
    const rowSpacing = 16.0;

    
    final isCompact = availableWidth < 1200;

   
    final telemetryColWidth = isCompact ? availableWidth : availableWidth * 0.20;
    final cameraColWidth = isCompact ? availableWidth : availableWidth * 0.26;
    // Map takes whatever's left; on compact screens it gets full width too.

    final cameraHeight = cameraCollapsed ? 56.0 : 380.0;
    final survivorsHeight = cameraCollapsed ? 624.0 : 300.0;
    final topRowHeight = cameraHeight + rowSpacing + survivorsHeight;

    final telemetryColumn = SizedBox(
      width: telemetryColWidth,
      height: isCompact ? 500 : null,
      child: Column(
        children: [
          Expanded(child: TelemetryCard(mission: mission)),
          const SizedBox(height: 16),
          Expanded(child: MissionProgress(mission: mission)),
        ],
      ),
    );

    final mapPanel = SizedBox(
      height: isCompact ? 500 : topRowHeight,
      width: isCompact ? availableWidth : null,
      child: LiveMapGrid(mission: mission),
    );

    final cameraColumn = SizedBox(
      width: cameraColWidth,
      height: isCompact ? topRowHeight : null,
      child: Column(
        children: [
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
    );

    final topSection = isCompact
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              telemetryColumn,
              const SizedBox(height: rowSpacing),
              mapPanel,
              const SizedBox(height: rowSpacing),
              cameraColumn,
            ],
          )
        : SizedBox(
            height: topRowHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                telemetryColumn,
                const SizedBox(width: rowSpacing),
                Expanded(child: mapPanel),
                const SizedBox(width: rowSpacing),
                cameraColumn,
              ],
            ),
          );

    final bottomRow = isCompact
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 300, child: MissionTimelinePanel(mission: mission)),
              const SizedBox(height: rowSpacing),
              SizedBox(height: 260, child: MissionControlsPanel(mission: mission)),
              const SizedBox(height: rowSpacing),
              SizedBox(height: 260, child: NotificationsPanel(mission: mission)),
            ],
          )
        : SizedBox(
            height: 300,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 2, child: MissionTimelinePanel(mission: mission)),
                const SizedBox(width: rowSpacing),
                Expanded(child: MissionControlsPanel(mission: mission)),
                const SizedBox(width: rowSpacing),
                Expanded(child: NotificationsPanel(mission: mission)),
              ],
            ),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        topSection,
        const SizedBox(height: rowSpacing),
        bottomRow,
        const SizedBox(height: rowSpacing),
      ],
    );
  }
}