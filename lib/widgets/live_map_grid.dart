import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:nidar/state/mission_state.dart';
import 'package:nidar/theme/app_theme.dart';

class LiveMapGrid extends StatefulWidget {
  final MissionState mission;

  const LiveMapGrid({
    super.key,
    required this.mission,
  });

  @override
  State<LiveMapGrid> createState() => _LiveMapGridState();
}

class _LiveMapGridState extends State<LiveMapGrid> {
  static const int rows = 15;
  static const int cols = 15;

  static const double cellSize = 34;
  static const double gap = 2;
  static const double header = 24;

  double zoom = 1;
  String? selectedCell;

  // Exact 15 x 15 obstacle layout
  static const Set<String> fixedObstacles = {
    // Top boundary
    'A1',
    'B1',
    'C1',
    'D1',
    'E1',
    'F1',
    'G1',
    'H1',
    'I1',
    'J1',
    'K1',
    'L1',
    'M1',
    'N1',
    'O1',

    // Left / right boundaries
    'A2',
    'O2',
    'A3',
    'O3',
    'A4',
    'O4',

    // Row 5
    'A5',
    'B5',
    'C5',
    'D5',
    'E5',
    'F5',
    'H5',
    'I5',
    'J5',
    'K5',
    'L5',
    'M5',
    'N5',
    'O5',

    // Vertical walls
    'F2',
    'F3',
    'F4',
    'K2',
    'K3',
    'K4',

    // Row 6
    'A6',
    'J6',
    'O6',

    // Row 7
    'A7',
    'J7',
    'O7',

    // Row 8
    'A8',
    'J8',
    'O8',

    // Row 9
    'A9',
    'D9',
    'E9',
    'F9',
    'G9',
    'H9',
    'I9',
    'J9',
    'O9',

    // Row 10
    'A10',
    'F10',
    'O10',

    // Row 11
    'A11',
    'F11',
    'O11',

    // Row 12
    'A12',
    'B12',
    'C12',
    'D12',
    'E12',
    'F12',
    'I12',
    'J12',
    'K12',
    'L12',
    'M12',
    'N12',
    'O12',

    // Row 13
    'A13',
    'O13',

    // Row 14
    'A14',
    'O14',

    // Bottom boundary
    'A15',
    'B15',
    'C15',
    'D15',
    'E15',
    'F15',
    'G15',
    'H15',
    'I15',
    'J15',
    'K15',
    'L15',
    'M15',
    'N15',
    'O15',
  };

  @override
  void initState() {
    super.initState();
    widget.mission.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.mission.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  int _col(String letter) {
    return letter.codeUnitAt(0) - 65;
  }

  int _row(String key) {
    final parsed = int.tryParse(key.substring(1));
    return parsed != null ? parsed - 1 : 0;
  }

  Offset _point(
    double x,
    double y,
  ) {
    final col = x.floor().clamp(0, cols - 1);
    final row = y.floor().clamp(0, rows - 1);

    return Offset(
      header +
          col * (cellSize + gap) +
          cellSize / 2,
      header +
          row * (cellSize + gap) +
          cellSize / 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: p.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'LIVE 2D MAP',
                  style: TextStyle(
                    color: p.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),

                _button(
                  p,
                  Icons.add,
                  () {
                    setState(() {
                      zoom = math.min(
                        2,
                        zoom + .15,
                      );
                    });
                  },
                ),

                const SizedBox(width: 6),

                _button(
                  p,
                  Icons.remove,
                  () {
                    setState(() {
                      zoom = math.max(
                        .6,
                        zoom - .15,
                      );
                    });
                  },
                ),

                const SizedBox(width: 6),

                _button(
                  p,
                  Icons.center_focus_strong,
                  () {
                    setState(() {
                      zoom = 1;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 14),

            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection:
                      Axis.horizontal,
                  child: SingleChildScrollView(
                    child: Transform.scale(
                      scale: zoom,
                      alignment:
                          Alignment.topLeft,
                      child: _map(p),
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
                _legend(
                  p,
                  p.accent,
                  Icons.flight,
                  'Drone',
                ),
                _legend(
                  p,
                  p.success,
                  Icons.crop_square,
                  'Explored',
                ),
                _legend(
                  p,
                  p.textSecondary,
                  Icons.crop_square,
                  'Unknown',
                ),
                _legend(
                  p,
                  const Color(0xFF68707A),
                  Icons.block,
                  'Obstacle',
                ),
                _legend(
                  p,
                  p.danger,
                  Icons.person,
                  'Survivor',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _button(
    AppPalette p,
    IconData icon,
    VoidCallback action,
  ) {
    return InkWell(
      onTap: action,
      borderRadius:
          BorderRadius.circular(7),
      child: Container(
        padding:
            const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: p.surface2,
          borderRadius:
              BorderRadius.circular(7),
          border: Border.all(
            color: p.border,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: p.textSecondary,
        ),
      ),
    );
  }

  Widget _map(AppPalette p) {
    final width =
        header +
        cols * (cellSize + gap);

    final height =
        header +
        rows * (cellSize + gap);

    final drone = _point(
      widget.mission.droneX,
      widget.mission.droneY,
    );

    final path =
        widget.mission.dronePath
            .map(
              (point) => _point(
                point['x'] ?? 0,
                point['y'] ?? 0,
              ),
            )
            .toList();

    final letters =
        List.generate(
      cols,
      (i) =>
          String.fromCharCode(
        65 + i,
      ),
    );

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: header,
                child: Row(
                  children: [
                    const SizedBox(
                      width: header,
                    ),

                    ...letters.map(
                      (letter) =>
                          SizedBox(
                        width:
                            cellSize + gap,
                        child: Center(
                          child: Text(
                            letter,
                            style:
                                TextStyle(
                              color:
                                  p.textSecondary,
                              fontSize: 11,
                              fontWeight:
                                  FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              for (
                int r = 0;
                r < rows;
                r++
              )
                SizedBox(
                  height:
                      cellSize + gap,
                  child: Row(
                    children: [
                      SizedBox(
                        width: header,
                        child: Center(
                          child: Text(
                            '${r + 1}',
                            style:
                                TextStyle(
                              color:
                                  p.textSecondary,
                              fontSize: 11,
                              fontWeight:
                                  FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      for (
                        int c = 0;
                        c < cols;
                        c++
                      )
                        _cell(
                          p,
                          letters[c],
                          r,
                        ),
                    ],
                  ),
                ),
            ],
          ),

          IgnorePointer(
            child: CustomPaint(
              size: Size(
                width,
                height,
              ),
              painter:
                  _PathPainter(
                points: path,
                color: p.accent,
              ),
            ),
          ),

          Positioned(
            left: drone.dx - 10,
            top: drone.dy - 10,
            child: IgnorePointer(
              child: Container(
                width: 20,
                height: 20,
                decoration:
                    BoxDecoration(
                  shape:
                      BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                          p.accent
                              .withValues(
                        alpha: .65,
                      ),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: DroneIcon(
                  color: p.accent,
                  size: 20,
                ),
              ),
            ),
          ),

          if (selectedCell != null)
            _tooltip(
              p,
              selectedCell!,
              width,
              height,
            ),
        ],
      ),
    );
  }

  Widget _cell(
    AppPalette p,
    String letter,
    int row,
  ) {
    final key =
        '$letter${row + 1}';

    final col = _col(letter);

    final backendKey =
        '$row,$col';

    final backendValue =
        widget.mission
            .occupancyGrid[
          backendKey
        ];

    final isWall =
        fixedObstacles.contains(key) ||
        backendValue == 1;

    final isUnknown =
        !isWall &&
        (backendValue == null ||
            backendValue == 2);

    final isExplored =
        !isWall &&
        backendValue == 0;

    final survivorList =
        widget.mission.survivors
            .where(
      (s) =>
          s.grid.toUpperCase() ==
          key,
    );

    final survivor =
        survivorList.isNotEmpty &&
                !isWall &&
                !isUnknown
            ? survivorList.first
            : null;

    Color background;
    Color border;

    // ============================================================
    // GREY OBSTACLE STYLE
    // ============================================================
    if (isWall) {
      background =
          const Color(0xFF30353D);

      border =
          const Color(0xFF4A515B);
    } else if (isUnknown) {
      background =
          p.bg.withValues(
        alpha: .95,
      );

      border =
          p.border.withValues(
        alpha: .60,
      );
    } else {
      background =
          p.success.withValues(
        alpha: .16,
      );

      border =
          p.success.withValues(
        alpha: .48,
      );
    }

    Widget content =
        const SizedBox();

    // Survivor
    if (survivor != null) {
      content = Center(
        child: Container(
          width: 24,
          height: 24,
          decoration:
              BoxDecoration(
            shape:
                BoxShape.circle,
            color: p.danger,
            boxShadow: [
              BoxShadow(
                color:
                    p.danger.withValues(
                  alpha: .80,
                ),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.location_on,
            color: Colors.white,
            size: 17,
          ),
        ),
      );
    }

    // Mission entrance
    else if (key == 'B2') {
      content = Center(
        child: Container(
          width: 22,
          height: 22,
          decoration:
              BoxDecoration(
            border: Border.all(
              color: p.warning,
              width: 1.5,
            ),
            borderRadius:
                BorderRadius.circular(
              4,
            ),
            color:
                p.warning.withValues(
              alpha: .12,
            ),
          ),
          child: Icon(
            Icons.login,
            color: p.warning,
            size: 17,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCell =
              selectedCell == key
                  ? null
                  : key;
        });
      },

      child: Container(
        width: cellSize,
        height: cellSize,

        margin:
            const EdgeInsets.all(
          gap / 2,
        ),

        decoration:
            BoxDecoration(
          color: background,

          border: Border.all(
            color:
                selectedCell == key
                    ? p.accent
                    : border,
            width:
                selectedCell == key
                    ? 2
                    : 1,
          ),

          borderRadius:
              BorderRadius.circular(
            4,
          ),

          // No obstacle glow.
          // Only explored cells have a tiny green glow.
          boxShadow: isExplored
              ? [
                  BoxShadow(
                    color: p.success
                        .withValues(
                      alpha: .08,
                    ),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),

        child: Stack(
          children: [
            // ====================================================
            // VERY SUBTLE GREY DIAGONAL TEXTURE
            // ====================================================
            if (isWall)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(
                    4,
                  ),
                  child:
                      CustomPaint(
                    painter:
                        _WallPainter(
                      color:
                          const Color(
                        0xFF3C424B,
                      ),
                    ),
                  ),
                ),
              ),

            // Unknown-cell texture
            if (isUnknown)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(
                    4,
                  ),
                  child:
                      CustomPaint(
                    painter:
                        _UnknownPainter(
                      color:
                          p.border
                              .withValues(
                        alpha: .28,
                      ),
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

  Widget _tooltip(
    AppPalette p,
    String key,
    double width,
    double height,
  ) {
    final col =
        _col(key[0]);

    final row =
        _row(key);

    final backendValue =
        widget.mission
            .occupancyGrid[
          '$row,$col'
        ];

    final isWall =
        fixedObstacles.contains(key) ||
        backendValue == 1;

    final value =
        isWall
            ? 1
            : backendValue ?? 2;

    final survivorList =
        widget.mission.survivors
            .where(
      (s) =>
          s.grid.toUpperCase() ==
          key,
    );

    final hasSurvivor =
        survivorList.isNotEmpty &&
        !isWall &&
        value != 2;

    final center = Offset(
      header +
          col *
              (cellSize + gap) +
          cellSize / 2,
      header +
          row *
              (cellSize + gap) +
          cellSize / 2,
    );

    const tooltipWidth =
        190.0;

    double left =
        center.dx + 10;

    if (left + tooltipWidth >
        width) {
      left =
          center.dx -
              tooltipWidth -
              10;
    }

    left = left.clamp(
      0,
      math.max(
        0,
        width - tooltipWidth,
      ),
    );

    double top =
        center.dy - 60;

    top = top.clamp(
      0,
      math.max(
        0,
        height - 140,
      ),
    );

    final status =
        value == 1
            ? 'Obstacle'
            : value == 0
                ? 'Explored'
                : 'Unknown';

    final statusColor =
        value == 1
            ? const Color(
                0xFF68707A,
              )
            : value == 0
                ? p.success
                : p.textSecondary;

    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: tooltipWidth,
        padding:
            const EdgeInsets.all(
          12,
        ),
        decoration:
            BoxDecoration(
          color: p.surface2,
          borderRadius:
              BorderRadius.circular(
            9,
          ),
          border: Border.all(
            color: value == 1
                ? const Color(
                    0xFF4A515B,
                  )
                : p.border,
          ),
          boxShadow: const [
            BoxShadow(
              color:
                  Colors.black45,
              blurRadius: 12,
              offset: Offset(
                0,
                4,
              ),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    key,
                    style:
                        TextStyle(
                      color:
                          p.textPrimary,
                      fontWeight:
                          FontWeight
                              .w700,
                    ),
                  ),
                ),

                InkWell(
                  onTap: () {
                    setState(() {
                      selectedCell =
                          null;
                    });
                  },
                  child: Icon(
                    Icons.close,
                    size: 15,
                    color:
                        p.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 7,
            ),

            Text(
              'Status: $status',
              style: TextStyle(
                color:
                    statusColor,
                fontSize: 12,
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            const SizedBox(
              height: 3,
            ),

            Text(
              'Drone X: '
              '${widget.mission.droneX.toStringAsFixed(1)}',
              style:
                  TextStyle(
                color:
                    p.textSecondary,
                fontSize: 12,
              ),
            ),

            Text(
              'Drone Y: '
              '${widget.mission.droneY.toStringAsFixed(1)}',
              style:
                  TextStyle(
                color:
                    p.textSecondary,
                fontSize: 12,
              ),
            ),

            Text(
              'Survivor: '
              '${hasSurvivor ? 'Yes' : 'No'}',
              style:
                  TextStyle(
                color: hasSurvivor
                    ? p.danger
                    : p.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legend(
    AppPalette p,
    Color color,
    IconData icon,
    String text,
  ) {
    return Row(
      mainAxisSize:
          MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: color,
        ),
        const SizedBox(
          width: 5,
        ),
        Text(
          text,
          style: TextStyle(
            color:
                p.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class DroneIcon
    extends StatelessWidget {
  final Color color;
  final double size;

  const DroneIcon({
    super.key,
    required this.color,
    this.size = 20,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return CustomPaint(
      size: Size(
        size,
        size,
      ),
      painter:
          _DronePainter(color),
    );
  }
}

class _DronePainter
    extends CustomPainter {
  final Color color;

  _DronePainter(this.color);

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final arm =
        size.width * .32;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..strokeCap =
          StrokeCap.round;

    final rotor = Paint()
      ..color = color
      ..style =
          PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final points = [
      center +
          Offset(
            -arm,
            -arm,
          ),
      center +
          Offset(
            arm,
            -arm,
          ),
      center +
          Offset(
            -arm,
            arm,
          ),
      center +
          Offset(
            arm,
            arm,
          ),
    ];

    for (final point
        in points) {
      canvas.drawLine(
        center,
        point,
        paint,
      );

      canvas.drawCircle(
        point,
        size.width * .13,
        rotor,
      );
    }

    canvas.drawCircle(
      center,
      size.width * .14,
      paint,
    );
  }

  @override
  bool shouldRepaint(
    covariant _DronePainter
        oldDelegate,
  ) {
    return oldDelegate.color !=
        color;
  }
}

class _WallPainter
    extends CustomPainter {
  final Color color;

  _WallPainter({
    required this.color,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.7;

    const spacing = 8.0;

    for (
      double x = -size.height;
      x < size.width;
      x += spacing
    ) {
      canvas.drawLine(
        Offset(
          x,
          0,
        ),
        Offset(
          x + size.height,
          size.height,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant _WallPainter
        oldDelegate,
  ) {
    return oldDelegate.color !=
        color;
  }
}

class _UnknownPainter
    extends CustomPainter {
  final Color color;

  _UnknownPainter({
    required this.color,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()
      ..color = color
      ..style =
          PaintingStyle.fill;

    const spacing = 7.0;

    for (
      double y = 3;
      y < size.height;
      y += spacing
    ) {
      for (
        double x = 3;
        x < size.width;
        x += spacing
      ) {
        canvas.drawCircle(
          Offset(
            x,
            y,
          ),
          .8,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(
    covariant _UnknownPainter
        oldDelegate,
  ) {
    return oldDelegate.color !=
        color;
  }
}

class _PathPainter
    extends CustomPainter {
  final List<Offset> points;
  final Color color;

  _PathPainter({
    required this.points,
    required this.color,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    if (points.length < 2) {
      return;
    }

    final path = Path();

    path.moveTo(
      points.first.dx,
      points.first.dy,
    );

    for (
      int i = 1;
      i < points.length;
      i++
    ) {
      path.lineTo(
        points[i].dx,
        points[i].dy,
      );
    }

    final paint = Paint()
      ..color =
          color.withValues(
        alpha: .85,
      )
      ..strokeWidth = 2
      ..style =
          PaintingStyle.stroke
      ..strokeCap =
          StrokeCap.round;

    for (
      final metric
          in path.computeMetrics()
    ) {
      double distance = 0;

      while (
          distance <
              metric.length) {
        final end =
            math.min(
          distance + 6,
          metric.length,
        );

        canvas.drawPath(
          metric.extractPath(
            distance,
            end,
          ),
          paint,
        );

        distance =
            end + 4;
      }
    }
  }

  @override
  bool shouldRepaint(
    covariant _PathPainter
        oldDelegate,
  ) {
    return oldDelegate.points !=
            points ||
        oldDelegate.color !=
            color;
  }
}