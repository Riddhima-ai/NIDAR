// lib/widgets/live_map_grid.dart
import 'dart:async';
import 'dart:math' as math;
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
  String? selectedKey;

  static const cols = 9;
  static const rows = 9;
  static const cellSize = 42.0;
  static const cellMargin = 1.0;
  static const pitch = cellSize + cellMargin * 2;
  static const headerSize = 24.0;

  // Route the drone walks from entry to exit. (No walls sit on this
  // route -- check `walls` below before editing it.) Static so
  // `stepDuration` below can size itself off `route.length`.
  static const List<String> route = [
    'A2', 'B2', 'B3', 'C3', 'D3', 'E3', 'F3', 'F4', 'G4', 'G5', 'H5',
  ];

  // How long the FULL sweep (entry to exit) should take. This is the
  // one knob to turn if the drone still feels out of step with the
  // rest of the mission dashboard -- e.g. set it closer to whatever
  // "Time Elapsed" / "Max Flight Time" actually reflects for a real
  // mission, rather than tuning the per-step delay directly.
  static const routeDuration = Duration(minutes: 2);

  // Derived: routeDuration spread evenly across every step in the
  // route, so the sweep takes routeDuration total no matter how many
  // cells are in it.
  static final stepDuration = Duration(
    milliseconds: (routeDuration.inMilliseconds / (route.length - 1)).round(),
  );

  // How far out (in grid cells, Chebyshev-ish box) the drone's sensors
  // "see" from wherever it currently is. This is what lets survivors
  // that sit a cell or two off the exact route get discovered while
  // the drone is passing nearby, instead of only revealing whatever
  // cell it's literally standing on.
  static const scanRadius = 2;

  // Obstacles are the only thing that's fixed/static -- everything
  // else (coverage, drone position) is driven by the mission.
  final walls = <String>{
    'C1', 'D1', 'E2', 'G2', 'H3', 'A4', 'H4', 'A6', 'H6', 'B7', 'H8', 'D7',
    'E7',
  };

  static const entryKey = 'A2';
  static const exitKey = 'H5';

  int _step = 0; // index into `route` -- how far the drone has moved
  Timer? _timer;
  MissionPhase? _lastPhase;
  final Set<String> _covered = {}; // cells revealed as "explored" so far

  @override
  void initState() {
    super.initState();
    _lastPhase = widget.mission.phase;
    _covered.add(entryKey);
    widget.mission.addListener(_onMissionChanged);
  }

  @override
  void dispose() {
    widget.mission.removeListener(_onMissionChanged);
    _timer?.cancel();
    super.dispose();
  }

  void _onMissionChanged() {
    final phase = widget.mission.phase;
    if (phase == _lastPhase) return;
    _lastPhase = phase;

    switch (phase) {
      case MissionPhase.idle:
        _resetRoute();
        break;
      case MissionPhase.active:
        _startTimer();
        break;
      case MissionPhase.paused:
        _timer?.cancel();
        break;
      case MissionPhase.aborted:
        _timer?.cancel();
        break;
      case MissionPhase.completed:
        _timer?.cancel();
        // Snap to the end in case the mission finished faster than
        // the step animation did. This also acts as a safety net --
        // any survivor that never fell inside the swept coverage
        // (e.g. it sits off the route entirely) still gets revealed
        // once the mission wraps up, instead of staying hidden forever.
        setState(() {
          _step = route.length - 1;
          _covered.addAll(route);
          for (final k in route) {
            _covered.addAll(_cellsInRadius(k, scanRadius));
          }
        });
        break;
      case MissionPhase.returning:
        // Let the drone keep animating toward the exit.
        if (_timer == null || !_timer!.isActive) _startTimer();
        break;
    }
  }

  void _resetRoute() {
    _timer?.cancel();
    setState(() {
      _step = 0;
      _covered
        ..clear()
        ..add(entryKey);
    });
  }

  void _startTimer() {
    _timer?.cancel();
    if (_step >= route.length - 1) return;
    _timer = Timer.periodic(stepDuration, (t) {
      if (_step >= route.length - 1) {
        t.cancel();
        return;
      }
      setState(() {
        _step++;
        final here = route[_step];
        _covered.add(here);
        _covered.addAll(_cellsInRadius(here, scanRadius));
      });
    });
  }

  List<String> _neighborsOf(String key) {
    final letters = List.generate(cols, (i) => String.fromCharCode(65 + i));
    final colIndex = letters.indexOf(key[0]);
    final row = int.parse(key.substring(1));
    final candidates = <String>[];
    if (colIndex > 0) candidates.add('${letters[colIndex - 1]}$row');
    if (colIndex < cols - 1) candidates.add('${letters[colIndex + 1]}$row');
    if (row > 1) candidates.add('${key[0]}${row - 1}');
    if (row < rows) candidates.add('${key[0]}${row + 1}');
    return candidates.where((k) => !walls.contains(k)).toList();
  }

  /// All cells within `radius` grid-steps of `key` (a small square
  /// scan area, not just the 4 direct neighbors). This is what powers
  /// the "find survivors on the way" behavior -- it reveals a patch
  /// around wherever the drone currently is, not a single cell.
  List<String> _cellsInRadius(String key, int radius) {
    final letters = List.generate(cols, (i) => String.fromCharCode(65 + i));
    final colIndex = letters.indexOf(key[0]);
    final row = int.parse(key.substring(1));
    final result = <String>[];
    for (int dc = -radius; dc <= radius; dc++) {
      final c = colIndex + dc;
      if (c < 0 || c >= cols) continue;
      for (int dr = -radius; dr <= radius; dr++) {
        final r = row + dr;
        if (r < 1 || r > rows) continue;
        final k = '${letters[c]}$r';
        if (walls.contains(k)) continue;
        result.add(k);
      }
    }
    return result;
  }

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
                  width: 8,
                  height: 8,
                  decoration:
                      BoxDecoration(color: p.success, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text('LIVE 2D MAP',
                    style: TextStyle(
                        color: p.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        letterSpacing: 0.5)),
                const Spacer(),
                _allLayersChip(p),
                const SizedBox(width: 10),
                _zoomBtn(p, Icons.add,
                    () => setState(() => zoom = (zoom + 0.15).clamp(0.6, 2.0))),
                const SizedBox(width: 6),
                _zoomBtn(p, Icons.remove,
                    () => setState(() => zoom = (zoom - 0.15).clamp(0.6, 2.0))),
                const SizedBox(width: 6),
                _zoomBtn(p, Icons.center_focus_strong_outlined,
                    () => setState(() => zoom = 1.0)),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: _zoomedGrid(p),
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
                _legendDroneChip(p),
                _legendPathChip(p),
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

  /// Wraps the grid in a SizedBox that actually grows with `zoom`, so
  /// the surrounding ScrollViews know there's more content to scroll
  /// to instead of clipping it. This is the fix for the zoom bug --
  /// Transform.scale alone doesn't expand the layout box it sits in.
  Widget _zoomedGrid(AppPalette p) {
    final gridWidth = headerSize + cols * pitch;
    final gridHeight = headerSize + rows * pitch;
    return SizedBox(
      width: gridWidth * zoom,
      height: gridHeight * zoom,
      child: Transform.scale(
        scale: zoom,
        alignment: Alignment.topLeft,
        child: _buildGrid(p),
      ),
    );
  }

  Widget _allLayersChip(AppPalette p) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: p.surface2,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: p.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.layers_outlined, size: 15, color: p.textSecondary),
            const SizedBox(width: 6),
            Text('All Layers',
                style: TextStyle(color: p.textSecondary, fontSize: 12)),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, size: 15, color: p.textSecondary),
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

  Widget _legendDroneChip(AppPalette p) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DroneIcon(color: p.accent, size: 14),
        const SizedBox(width: 6),
        Text('Drone', style: TextStyle(color: p.textSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _legendPathChip(AppPalette p) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 16,
          height: 14,
          child: CustomPaint(painter: _DashSwatchPainter(color: p.accent)),
        ),
        const SizedBox(width: 6),
        Text('Path', style: TextStyle(color: p.textSecondary, fontSize: 12)),
      ],
    );
  }

  Offset _centerFor(String key) {
    final letters = List.generate(cols, (i) => String.fromCharCode(65 + i));
    final colIndex = letters.indexOf(key[0]);
    final row = int.parse(key.substring(1));
    final x = headerSize + colIndex * pitch + pitch / 2;
    final y = headerSize + (row - 1) * pitch + pitch / 2;
    return Offset(x, y);
  }

  Widget _buildGrid(AppPalette p) {
    final letters = List.generate(cols, (i) => String.fromCharCode(65 + i));
    final gridWidth = headerSize + cols * pitch;
    final gridHeight = headerSize + rows * pitch;

    final currentDrone = route[_step];
    // Only draw the trail up to how far the drone has actually moved.
    final walked = route.sublist(0, _step + 1).map(_centerFor).toList();

    return SizedBox(
      width: gridWidth,
      height: gridHeight,
      child: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: headerSize,
                child: Row(
                  children: [
                    const SizedBox(width: headerSize),
                    ...letters.map((l) => SizedBox(
                          width: pitch,
                          child: Center(
                              child: Text(l,
                                  style: TextStyle(
                                      color: p.textSecondary, fontSize: 11))),
                        )),
                  ],
                ),
              ),
              for (int r = 1; r <= rows; r++)
                SizedBox(
                  height: pitch,
                  child: Row(
                    children: [
                      SizedBox(
                        width: headerSize,
                        child: Center(
                            child: Text('$r',
                                style: TextStyle(
                                    color: p.textSecondary, fontSize: 11))),
                      ),
                      for (int c = 0; c < cols; c++)
                        _cell(p, letters[c], r, currentDrone),
                    ],
                  ),
                ),
            ],
          ),

          IgnorePointer(
            child: CustomPaint(
              size: Size(gridWidth, gridHeight),
              painter: _DashedPathPainter(points: walked, color: p.accent),
            ),
          ),

          if (selectedKey != null)
            _tooltipCard(p, selectedKey!, gridWidth, gridHeight),
        ],
      ),
    );
  }

  Widget _cell(AppPalette p, String colLetter, int row, String currentDrone) {
    final key = '$colLetter$row';
    final isDrone = key == currentDrone;
    final isEntry = key == entryKey;
    final isExit = key == exitKey;
    final isWall = walls.contains(key);
    final isCovered = _covered.contains(key);

    // Survivors are only revealed once the drone's sweep has actually
    // covered their cell -- this is what makes discovery happen
    // progressively alongside the movement instead of all survivors
    // popping in together at the start or end.
    final survivorMatches =
        widget.mission.survivors.where((s) => s.grid == key);
    final survivor =
        survivorMatches.isNotEmpty && isCovered ? survivorMatches.first : null;

    Color fill = p.bg;
    Color borderColor = p.border;
    List<BoxShadow> glow = const [];

    if (isCovered && !isWall) {
      fill = p.success.withValues(alpha: 0.16);
      borderColor = p.success.withValues(alpha: 0.45);
      glow = [
        BoxShadow(
          color: p.success.withValues(alpha: 0.18),
          blurRadius: 6,
          spreadRadius: 0.5,
        ),
      ];
    }

    Widget content = const SizedBox.shrink();

    // Drone marker takes priority over entry/exit icons if it's
    // currently sitting on that cell.
    if (isDrone) {
      content = Center(
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: p.accent.withValues(alpha: 0.55),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: DroneIcon(color: p.accent, size: 20),
        ),
      );
    } else if (survivor != null) {
      final confidence = (survivor.confidence.clamp(0, 100)) / 100.0;
      content = Center(
        child: SizedBox(
          width: 30,
          height: 30,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: p.danger.withValues(alpha: 0.45),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              CustomPaint(
                size: const Size(30, 30),
                painter: _ConfidenceRingPainter(
                  progress: confidence,
                  color: confidence >= 0.9 ? p.success : p.warning,
                  trackColor: p.border,
                ),
              ),
              Icon(Icons.location_on, color: p.danger, size: 18),
            ],
          ),
        ),
      );
    } else if (isEntry) {
      content = Center(
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            border: Border.all(color: p.warning, width: 1.4),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(Icons.login, color: p.warning, size: 14),
        ),
      );
    } else if (isExit) {
      content = Center(
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            border: Border.all(color: p.danger, width: 1.4),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(Icons.logout, color: p.danger, size: 14),
        ),
      );
    }

    return GestureDetector(
      onTap: () => setState(
        () => selectedKey = selectedKey == key ? null : key,
      ),
      child: Container(
        width: cellSize,
        height: cellSize,
        margin: const EdgeInsets.all(cellMargin),
        decoration: BoxDecoration(
          color: fill,
          border: Border.all(
            color: selectedKey == key ? p.accent : borderColor,
            width: selectedKey == key ? 1.4 : 0.6,
          ),
          borderRadius: BorderRadius.circular(4),
          boxShadow: glow,
        ),
        child: Stack(
          children: [
            if (isWall)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: CustomPaint(
                    painter: _HatchPainter(
                      color: p.textSecondary.withValues(alpha: 0.35),
                    ),
                  ),
                ),
              ),
            content,
          ],
        ),
      ),
    );
  }

  Widget _tooltipCard(
      AppPalette p, String key, double gridWidth, double gridHeight) {
    const cardWidth = 200.0;
    final center = _centerFor(key);

    double left = center.dx + pitch / 2 + 8;
    if (left + cardWidth > gridWidth) {
      left = center.dx - pitch / 2 - 8 - cardWidth;
    }
    left = left.clamp(0.0, math.max(0.0, gridWidth - cardWidth));
    double top = (center.dy - 70).clamp(0.0, math.max(0.0, gridHeight - 160));

    final isWall = walls.contains(key);
    final isCovered = _covered.contains(key);

    // Same reveal rule as the cell itself: an undiscovered survivor
    // shouldn't be spoiled through the tooltip either.
    final survivorMatches =
        widget.mission.survivors.where((s) => s.grid == key);
    final survivor =
        survivorMatches.isNotEmpty && isCovered ? survivorMatches.first : null;

    final status =
        isWall ? 'Obstacle' : (isCovered ? 'Explored' : 'Unexplored');
    final statusColor =
        isWall ? p.textSecondary : (isCovered ? p.success : p.textSecondary);

    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: cardWidth,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: p.surface2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: p.border),
          boxShadow: const [
            BoxShadow(color: Colors.black45, blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(key,
                      style: TextStyle(
                          color: p.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
                ),
                InkWell(
                  onTap: () => setState(() => selectedKey = null),
                  child: Icon(Icons.close, size: 15, color: p.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _tooltipRow(p, 'Status', status, valueColor: statusColor),
            _tooltipRow(p, 'Terrain', isWall ? 'Blocked' : 'Clear'),
            _tooltipRow(p, 'RSSI',
                '${widget.mission.signalDbm.toStringAsFixed(0)} dBm'),
            _tooltipRow(
              p,
              'Survivor',
              survivor != null ? 'Survivor ${survivor.id}' : 'None',
              valueColor: survivor != null ? p.danger : p.textPrimary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _tooltipRow(AppPalette p, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text('$label: ',
              style: TextStyle(color: p.textSecondary, fontSize: 12.5)),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: valueColor ?? p.textPrimary,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A small top-down quadcopter glyph (body + 4 arms + rotor rings),
/// since Flutter's Material Icons don't include an actual drone shape.
class DroneIcon extends StatelessWidget {
  final Color color;
  final double size;
  const DroneIcon({super.key, required this.color, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _DroneIconPainter(color: color),
    );
  }
}

class _DroneIconPainter extends CustomPainter {
  final Color color;
  _DroneIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final armLen = size.width * 0.34;
    final rotorRadius = size.width * 0.16;

    final armPaint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.07
      ..strokeCap = StrokeCap.round;
    final rotorPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06;
    final bodyPaint = Paint()..color = color;

    final corners = [
      center + Offset(-armLen, -armLen),
      center + Offset(armLen, -armLen),
      center + Offset(-armLen, armLen),
      center + Offset(armLen, armLen),
    ];

    for (final corner in corners) {
      canvas.drawLine(center, corner, armPaint);
      canvas.drawCircle(corner, rotorRadius, rotorPaint);
    }

    final body = Rect.fromCenter(
      center: center,
      width: size.width * 0.34,
      height: size.height * 0.34,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, Radius.circular(size.width * 0.08)),
      bodyPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DroneIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _HatchPainter extends CustomPainter {
  final Color color;
  _HatchPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const gap = 6.0;
    for (double x = -size.height; x < size.width; x += gap) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HatchPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _ConfidenceRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;

  _ConfidenceRingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.width / 2 - 2;

    final track = Paint()
      ..color = trackColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, radius, track);

    final arc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _ConfidenceRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

class _DashedPathPainter extends CustomPainter {
  final List<Offset> points;
  final Color color;

  _DashedPathPainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    final paint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const dashLength = 6.0;
    const gapLength = 4.0;

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = math.min(distance + dashLength, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedPathPainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.color != color;
}

class _DashSwatchPainter extends CustomPainter {
  final Color color;
  _DashSwatchPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    const dash = 3.0;
    const gap = 2.0;
    double x = 0;
    final y = size.height / 2;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(math.min(x + dash, size.width), y), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashSwatchPainter oldDelegate) =>
      oldDelegate.color != color;
}