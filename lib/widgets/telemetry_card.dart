import 'package:flutter/material.dart';
import 'package:nidar/state/mission_state.dart';
import 'package:nidar/theme/app_theme.dart';

class TelemetryCard extends StatelessWidget {
  final MissionState mission;
  const TelemetryCard({super.key, required this.mission});

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
                Text(
                  'TELEMETRY',
                  style: TextStyle(
                    color: p.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.signal_cellular_alt,
                  size: 16,
                  color: p.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 6),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _rowWithGraph(
                      p,
                      icon: Icons.battery_full,
                      label: 'Battery',
                      value: '${mission.battery} %',
                      valueColor: mission.battery < 25 ? p.danger : p.success,
                      lineColor: p.success,
                      history: mission.batteryHistory,
                    ),
                    _rowWithGraph(
                      p,
                      icon: Icons.height,
                      label: 'Altitude',
                      value: '${mission.altitude.toStringAsFixed(1)} m',
                      valueColor: p.textPrimary,
                      lineColor: p.accent,
                      history: mission.altitudeHistory,
                    ),
                    _rowWithGraph(
                      p,
                      icon: Icons.speed,
                      label: 'Speed',
                      value: '${mission.speed.toStringAsFixed(1)} m/s',
                      valueColor: p.textPrimary,
                      lineColor: Colors.purpleAccent,
                      history: mission.speedHistory,
                    ),
                    _rowWithGraph(
                      p,
                      icon: Icons.wifi_tethering,
                      label: 'Signal Strength',
                      value: '${mission.signalDbm.toStringAsFixed(0)} dBm',
                      valueColor: p.textPrimary,
                      lineColor: Colors.amber,
                      history: mission.signalHistory,
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _statBox(
                            p,
                            icon: Icons.smart_toy_outlined,
                            label: 'Flight Mode',
                            value: 'AUTO',
                            valueColor: p.accent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _statBox(
                            p,
                            icon: Icons.thermostat,
                            label: 'Temperature',
                            value: '${mission.tempC.toStringAsFixed(0)} °C',
                            valueColor: p.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rowWithGraph(
    AppPalette p, {
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
    required Color lineColor,
    required List<double> history,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: p.textSecondary),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(color: p.textSecondary, fontSize: 13.5),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 32,
            width: double.infinity,
            child: Sparkline(
              data: history,
              lineColor: lineColor,
              fillGradient: [
                lineColor.withValues(alpha: 0.35),
                lineColor.withValues(alpha: 0.0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBox(
    AppPalette p, {
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      decoration: BoxDecoration(
        color: p.textSecondary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: p.textSecondary.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: p.textSecondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: p.textSecondary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// Lightweight sparkline / mini area-chart, no external chart package needed.
class Sparkline extends StatelessWidget {
  final List<double> data;
  final Color lineColor;
  final List<Color> fillGradient;
  final double strokeWidth;

  const Sparkline({
    super.key,
    required this.data,
    required this.lineColor,
    required this.fillGradient,
    this.strokeWidth = 1.6,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SparklinePainter(
        data: data,
        lineColor: lineColor,
        fillGradient: fillGradient,
        strokeWidth: strokeWidth,
      ),
      size: Size.infinite,
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final List<Color> fillGradient;
  final double strokeWidth;

  _SparklinePainter({
    required this.data,
    required this.lineColor,
    required this.fillGradient,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    double maxVal = data.first;
    double minVal = data.first;
    for (final v in data) {
      if (v > maxVal) maxVal = v;
      if (v < minVal) minVal = v;
    }
    final range = (maxVal - minVal).abs() < 1e-6 ? 1.0 : (maxVal - minVal);

    final stepX = size.width / (data.length - 1);
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final normalized = (data[i] - minVal) / range;
      final y = size.height - (normalized * size.height);
      points.add(Offset(x, y));
    }

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final mid = Offset((prev.dx + curr.dx) / 2, (prev.dy + curr.dy) / 2);
      linePath.quadraticBezierTo(prev.dx, prev.dy, mid.dx, mid.dy);
    }
    linePath.lineTo(points.last.dx, points.last.dy);

    final fillPath = Path.from(linePath)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: fillGradient,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.lineColor != lineColor;
  }
}
