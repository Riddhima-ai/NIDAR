// lib/widgets/live_map_grid.dart
import 'package:flutter/material.dart';
import 'package:nidar/state/mission_state.dart';
import 'package:nidar/theme/app_theme.dart';

class LiveMapGrid extends StatefulWidget {
  final MissionState mission;
  const LiveMapGrid({super.key, required this.mission});

  @override
  State<LiveMapGrid> createState() => _LiveMapGridState();
}

class _LiveMapGridState extends State<LiveMapGrid> {
  double zoom = 1.0;

  static const cols = 9;
  static const rows = 9;

  // Demo layout — swap for your real occupancy/SLAM grid.
  final explored = <String>{
    'B2','B3','C2','C3','D3','E3','F3','F4','G4','D4','D5','C5','B5',
    'C6','D6','F6','G6','F7','F8',
  };
  final walls = <String>{
    'C1','D1','E2','G2','H3','A4','H4','A6','H6','B7','H8','D7','E7',
  };

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(color: p.success, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text('LIVE 2D MAP',
                    style: TextStyle(
                        color: p.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        letterSpacing: 0.5)),
                const Spacer(),
                _zoomBtn(p, Icons.add, () => setState(() => zoom = (zoom + 0.15).clamp(0.6, 2.0))),
                const SizedBox(width: 6),
                _zoomBtn(p, Icons.remove, () => setState(() => zoom = (zoom - 0.15).clamp(0.6, 2.0))),
                const SizedBox(width: 6),
                _zoomBtn(p, Icons.center_focus_strong_outlined, () => setState(() => zoom = 1.0)),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: Transform.scale(
                      scale: zoom,
                      child: _buildGrid(p),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Wrap(
              spacing: 18,
              runSpacing: 8,
              children: [
                _legendChip(p, p.accent, Icons.navigation, 'Drone'),
                _legendChip(p, p.success, Icons.crop_square, 'Explored'),
                _legendChip(p, p.border, Icons.crop_square, 'Unexplored'),
                _legendChip(p, p.textSecondary, Icons.crop_square, 'Obstacle'),
                _legendChip(p, p.warning, Icons.add, 'Entry'),
                _legendChip(p, p.danger, Icons.arrow_forward, 'Exit'),
                _legendChip(p, p.danger, Icons.person, 'Survivor'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _zoomBtn(AppPalette p, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: p.surface2,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: p.border),
        ),
        child: Icon(icon, size: 16, color: p.textSecondary),
      ),
    );
  }

  Widget _legendChip(AppPalette p, Color color, IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: p.textSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _buildGrid(AppPalette p) {
    const cellSize = 42.0;
    final letters = List.generate(cols, (i) => String.fromCharCode(65 + i));

    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 24),
            ...letters.map((l) => SizedBox(
                  width: cellSize,
                  child: Center(
                      child: Text(l,
                          style: TextStyle(color: p.textSecondary, fontSize: 11))),
                )),
          ],
        ),
        for (int r = 1; r <= rows; r++)
          Row(
            children: [
              SizedBox(
                width: 24,
                child: Center(
                    child: Text('$r',
                        style: TextStyle(color: p.textSecondary, fontSize: 11))),
              ),
              for (int c = 0; c < cols; c++) _cell(p, letters[c], r, cellSize),
            ],
          ),
      ],
    );
  }

  Widget _cell(AppPalette p, String colLetter, int row, double size) {
    final key = '$colLetter$row';
    final isDrone = key == 'D4';
    final isEntry = key == 'A2';
    final isExit = key == 'H5';
    final survivor = widget.mission.survivors
        .where((s) => s.grid == key)
        .isNotEmpty;
    final isWall = walls.contains(key);
    final isExplored = explored.contains(key);

    Color fill = p.bg;
    Widget? marker;

    if (isWall) {
      fill = p.surface2;
    } else if (isExplored) {
      fill = p.successMuted;
    }

    if (isDrone) {
      marker = Icon(Icons.navigation, color: p.accent, size: 20);
    } else if (survivor) {
      marker = Icon(Icons.person_pin_circle, color: p.danger, size: 20);
    } else if (isEntry) {
      marker = Icon(Icons.login, color: p.warning, size: 16);
    } else if (isExit) {
      marker = Icon(Icons.logout, color: p.danger, size: 16);
    }

    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: fill,
        border: Border.all(color: p.border, width: 0.6),
        borderRadius: BorderRadius.circular(4),
      ),
      child: marker == null ? null : Center(child: marker),
    );
  }
}