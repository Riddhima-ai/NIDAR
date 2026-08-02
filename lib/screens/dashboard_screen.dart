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

  // ---- Fixed design metrics for the dashboard layout ----
  // These describe the desktop layout in image 2 exactly.
  // We NEVER change these based on screen size — instead we scale
  // the whole block uniformly to fit whatever width is available.
  static const double _sideColWidth = 320;
  static const double _mapWidth = 760;
  static const double _rightColWidth = 420;
  static const double _rowSpacing = 16;
  static const double _secondRowHeight = 300;

  double get _designWidth =>
      _sideColWidth + _rowSpacing + _mapWidth + _rowSpacing + _rightColWidth;

  double get _cameraHeight => cameraCollapsed ? 56.0 : 380.0;
  double get _survivorsHeight => cameraCollapsed ? 624.0 : 300.0;
  double get _topRowHeight => _cameraHeight + _rowSpacing + _survivorsHeight;

  double get _designHeight =>
      _topRowHeight + _rowSpacing + _secondRowHeight + _rowSpacing;

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
        content: const Text(
          'Immediately halt the mission and trigger recall/RTB?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
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
                Expanded(child: _buildBody()),
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
        // Scale the fixed desktop design to fit whatever width we get,
        // instead of letting it restack or overflow.
        return LayoutBuilder(
          builder: (context, constraints) {
            final scale = (constraints.maxWidth / _designWidth).clamp(
              0.45,
              1.4,
            );
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: _designWidth * scale,
                  height: _designHeight * scale,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: _designWidth,
                      height: _designHeight,
                      child: _dashboardBody(),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      case NavSection.map:
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SizedBox(height: 700, child: LiveMapGrid(mission: mission)),
        );
      case NavSection.survivors:
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SizedBox(height: 700, child: SurvivorsPanel(mission: mission)),
        );
      case NavSection.telemetry:
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SizedBox(height: 700, child: TelemetryCard(mission: mission)),
        );
      case NavSection.mission:
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 700,
            child: Column(
              children: [
                SizedBox(
                  height: 300,
                  child: MissionTimelinePanel(mission: mission),
                ),
                const SizedBox(height: 16),
                Expanded(child: MissionControlsPanel(mission: mission)),
              ],
            ),
          ),
        );
      case NavSection.camera:
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 700,
            child: CameraFullscreenView(
              mission: mission,
              onExitFullscreen: () {
                setState(() {
                  selected = NavSection.dashboard;
                });
              },
            ),
          ),
        );
      case NavSection.logs:
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 700,
            child: NotificationsPanel(mission: mission),
          ),
        );
    }
  }

  Widget _dashboardBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: _topRowHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: _sideColWidth,
                child: Column(
                  children: [
                    Expanded(child: TelemetryCard(mission: mission)),
                    const SizedBox(height: 16),
                    Expanded(child: MissionProgress(mission: mission)),
                  ],
                ),
              ),
              const SizedBox(width: _rowSpacing),
              SizedBox(
                width: _mapWidth,
                child: LiveMapGrid(mission: mission),
              ),
              const SizedBox(width: _rowSpacing),
              SizedBox(
                width: _rightColWidth,
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                      height: _cameraHeight,
                      child: CameraFeedPanel(
                        mission: mission,
                        collapsed: cameraCollapsed,
                        onToggleCollapse: () =>
                            setState(() => cameraCollapsed = !cameraCollapsed),
                        onExpand: () =>
                            setState(() => selected = NavSection.camera),
                      ),
                    ),
                    const SizedBox(height: _rowSpacing),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                      height: _survivorsHeight,
                      child: SurvivorsPanel(mission: mission),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: _rowSpacing),
        SizedBox(
          height: _secondRowHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 2, child: MissionTimelinePanel(mission: mission)),
              const SizedBox(width: _rowSpacing),
              Expanded(child: MissionControlsPanel(mission: mission)),
              const SizedBox(width: _rowSpacing),
              Expanded(child: NotificationsPanel(mission: mission)),
            ],
          ),
        ),
        const SizedBox(height: _rowSpacing),
      ],
    );
  }
}
