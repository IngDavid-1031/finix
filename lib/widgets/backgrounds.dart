import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Fondo con ondas verdes (oscuro para splash/menú, claro para login).
class WavesBackground extends StatelessWidget {
  final bool dark;
  final Widget child;
  const WavesBackground({super.key, this.dark = false, required this.child});

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned.fill(
        child: CustomPaint(painter: WavesPainter(dark: dark)),
      ),
      child,
    ],
  );
}

class WavesPainter extends CustomPainter {
  final bool dark;
  final bool paintBackground;
  WavesPainter({this.dark = false, this.paintBackground = true});

  Paint _grad(Rect r, Color c, double a1, double a2) =>
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            c.withValues(alpha: a1),
            c.withValues(alpha: a2),
          ],
        ).createShader(r);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final full = Offset.zero & size;

    if (dark) {
      if (paintBackground) {
        canvas.drawRect(
          full,
          Paint()
            ..shader = const RadialGradient(
              center: Alignment(0.3, -0.4),
              radius: 1.2,
              colors: [Color(0xFF0E6B45), Color(0xFF062B1C), AppColors.deep],
            ).createShader(full),
        );
      }
      // Brillo superior
      canvas.drawPath(
        Path()
          ..moveTo(w * 0.35, 0)
          ..cubicTo(w * 0.65, h * 0.18, w * 0.85, h * 0.02, w, h * 0.22)
          ..lineTo(w, 0)
          ..close(),
        _grad(full, AppColors.mint, 0.35, 0.05),
      );
      // Ondas inferiores
      canvas.drawPath(
        Path()
          ..moveTo(0, h * 0.58)
          ..cubicTo(w * 0.35, h * 0.46, w * 0.6, h * 0.78, w, h * 0.62)
          ..lineTo(w, h)
          ..lineTo(0, h)
          ..close(),
        _grad(
          Rect.fromLTWH(0, h * 0.5, w, h * 0.5),
          AppColors.mint,
          0.28,
          0.02,
        ),
      );
      canvas.drawPath(
        Path()
          ..moveTo(0, h * 0.78)
          ..cubicTo(w * 0.4, h * 0.62, w * 0.7, h * 0.98, w, h * 0.80)
          ..lineTo(w, h)
          ..lineTo(0, h)
          ..close(),
        _grad(
          Rect.fromLTWH(0, h * 0.7, w, h * 0.3),
          const Color(0xFF14A85E),
          0.45,
          0.1,
        ),
      );
      final line = Paint()
        ..color = AppColors.mint.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4;
      canvas.drawPath(
        Path()
          ..moveTo(0, h * 0.70)
          ..cubicTo(w * 0.3, h * 0.55, w * 0.65, h * 0.9, w, h * 0.70),
        line,
      );
      canvas.drawPath(
        Path()
          ..moveTo(0, h * 0.30)
          ..cubicTo(w * 0.4, h * 0.42, w * 0.6, h * 0.05, w, h * 0.12),
        line..color = AppColors.mint.withValues(alpha: 0.18),
      );
    } else {
      canvas.drawCircle(
        Offset(w * 1.05, -h * 0.02),
        w * 0.45,
        Paint()..color = AppColors.mint.withValues(alpha: 0.10),
      );
      canvas.drawPath(
        Path()
          ..moveTo(0, h * 0.86)
          ..cubicTo(w * 0.35, h * 0.78, w * 0.6, h * 0.98, w, h * 0.80)
          ..lineTo(w, h)
          ..lineTo(0, h)
          ..close(),
        Paint()..color = AppColors.mint.withValues(alpha: 0.16),
      );
      canvas.drawPath(
        Path()
          ..moveTo(w * 0.3, h)
          ..cubicTo(w * 0.55, h * 0.9, w * 0.8, h * 0.95, w, h * 0.86)
          ..lineTo(w, h)
          ..close(),
        Paint()..color = AppColors.green.withValues(alpha: 0.22),
      );
    }
  }

  @override
  bool shouldRepaint(covariant WavesPainter old) => old.dark != dark;
}
