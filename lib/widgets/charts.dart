import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class LineSeries {
  final List<double> values;
  final Color color;
  final bool fill;
  final double width;
  final bool endDot;

  const LineSeries(
    this.values, {
    required this.color,
    this.fill = true,
    this.width = 3,
    this.endDot = false,
  });
}

/// Gráfica de líneas suavizadas, sin dependencias externas.
class SmoothLineChart extends StatelessWidget {
  final List<LineSeries> series;
  final double? minY;
  final double? maxY;
  final List<String>? xLabels;
  final List<String>? yLabels; // de arriba hacia abajo
  final Color labelColor;
  final String? tooltip;

  const SmoothLineChart({
    super.key,
    required this.series,
    this.minY,
    this.maxY,
    this.xLabels,
    this.yLabels,
    this.labelColor = AppColors.muted,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.infinite, painter: _LinePainter(this));
}

class _LinePainter extends CustomPainter {
  final SmoothLineChart c;
  _LinePainter(this.c);

  void _text(
    Canvas canvas,
    String t,
    Offset at, {
    double align = 0.5,
    double size = 11,
    Color? color,
    FontWeight? weight,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: t,
        style: TextStyle(
          fontSize: size,
          color: color ?? c.labelColor,
          fontWeight: weight,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at - Offset(tp.width * align, tp.height / 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final all = c.series.expand((s) => s.values).toList();
    if (all.isEmpty) return;
    final lo = c.minY ?? all.reduce(math.min);
    final hi = c.maxY ?? all.reduce(math.max);
    final range = (hi - lo) == 0 ? 1.0 : hi - lo;

    final left = c.yLabels == null ? 4.0 : 36.0;
    final bottom = c.xLabels == null ? 4.0 : 26.0;
    final top = c.tooltip != null ? 38.0 : 8.0;
    final rect = Rect.fromLTRB(
      left,
      top,
      size.width - 10,
      size.height - bottom,
    );

    // Líneas guía + etiquetas Y
    if (c.yLabels != null) {
      final n = c.yLabels!.length;
      final grid = Paint()
        ..color = const Color(0xFFE8EEEA)
        ..strokeWidth = 1;
      for (var i = 0; i < n; i++) {
        final y = rect.top + rect.height * i / (n - 1);
        canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), grid);
        _text(
          canvas,
          c.yLabels![i],
          Offset(rect.left - 10, y),
          align: 1,
          size: 12,
        );
      }
    }

    // Etiquetas X
    if (c.xLabels != null) {
      final n = c.xLabels!.length;
      for (var i = 0; i < n; i++) {
        final x = rect.left + (n == 1 ? 0 : rect.width * i / (n - 1));
        _text(canvas, c.xLabels![i], Offset(x, rect.bottom + 15), size: 12);
      }
    }

    Offset? tooltipAnchor;
    for (final s in c.series) {
      final n = s.values.length;
      if (n < 2) continue;
      final pts = [
        for (var i = 0; i < n; i++)
          Offset(
            rect.left + rect.width * i / (n - 1),
            rect.bottom - rect.height * (s.values[i] - lo) / range,
          ),
      ];
      final path = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (var i = 0; i < n - 1; i++) {
        final a = pts[i], b = pts[i + 1];
        final mx = (a.dx + b.dx) / 2;
        path.cubicTo(mx, a.dy, mx, b.dy, b.dx, b.dy);
      }

      if (s.fill) {
        final fillPath = Path.from(path)
          ..lineTo(pts.last.dx, rect.bottom)
          ..lineTo(pts.first.dx, rect.bottom)
          ..close();
        canvas.drawPath(
          fillPath,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                s.color.withValues(alpha: 0.32),
                s.color.withValues(alpha: 0.0),
              ],
            ).createShader(rect),
        );
      }

      canvas.drawPath(
        path,
        Paint()
          ..color = s.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = s.width
          ..strokeCap = StrokeCap.round,
      );

      if (s.endDot) {
        final p = pts.last;
        canvas.drawCircle(
          p,
          8,
          Paint()..color = s.color.withValues(alpha: 0.25),
        );
        canvas.drawCircle(p, 5, Paint()..color = Colors.white);
        canvas.drawCircle(
          p,
          5,
          Paint()
            ..color = s.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5,
        );
      }
      tooltipAnchor ??= pts.last;
    }

    if (c.tooltip != null && tooltipAnchor != null) {
      final tp = TextPainter(
        text: TextSpan(
          text: c.tooltip,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final w = tp.width + 18, h = 26.0;
      var x = tooltipAnchor.dx - w / 2;
      x = x.clamp(0, size.width - w).toDouble();
      final y = tooltipAnchor.dy - h - 14;
      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, w, h),
        const Radius.circular(8),
      );
      final bg = Paint()..color = const Color(0xFF26332C);
      canvas.drawRRect(r, bg);
      canvas.drawPath(
        Path()
          ..moveTo(tooltipAnchor.dx - 5, y + h)
          ..lineTo(tooltipAnchor.dx + 5, y + h)
          ..lineTo(tooltipAnchor.dx, y + h + 5)
          ..close(),
        bg,
      );
      tp.paint(canvas, Offset(x + 9, y + (h - tp.height) / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter old) => true;
}

/// Gráfica de dona.
class DonutChart extends StatelessWidget {
  final List<(double, Color)> segments;
  final double thickness;
  final Widget? center;

  const DonutChart({
    super.key,
    required this.segments,
    this.thickness = 24,
    this.center,
  });

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _DonutPainter(segments, thickness),
    child: Center(child: center),
  );
}

class _DonutPainter extends CustomPainter {
  final List<(double, Color)> segments;
  final double thickness;
  _DonutPainter(this.segments, this.thickness);

  @override
  void paint(Canvas canvas, Size size) {
    final radius = math.min(size.width, size.height) / 2 - thickness / 2;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: radius,
    );
    final total = segments.fold<double>(0, (a, s) => a + s.$1);
    if (total == 0) return;
    var start = -math.pi / 2;
    for (final (value, color) in segments) {
      final sweep = 2 * math.pi * value / total;
      canvas.drawArc(
        rect,
        start,
        sweep,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = thickness,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => true;
}

/// Anillo de progreso con degradado.
class RingProgress extends StatelessWidget {
  final double value;
  final double thickness;
  final Widget? child;

  const RingProgress({
    super.key,
    required this.value,
    this.thickness = 16,
    this.child,
  });

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _RingPainter(value, thickness),
    child: Center(child: child),
  );
}

class _RingPainter extends CustomPainter {
  final double value;
  final double thickness;
  _RingPainter(this.value, this.thickness);

  @override
  void paint(Canvas canvas, Size size) {
    final radius = math.min(size.width, size.height) / 2 - thickness / 2;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: radius,
    );
    canvas.drawCircle(
      rect.center,
      radius,
      Paint()
        ..color = AppColors.greenSoft
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness,
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * value.clamp(0, 1),
      false,
      Paint()
        ..shader = const SweepGradient(
          colors: [AppColors.mint, Color(0xFF0E8A4F), AppColors.mint],
          transform: GradientRotation(-math.pi / 2),
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = thickness,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.value != value;
}
