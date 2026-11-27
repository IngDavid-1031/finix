import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/common.dart';
import 'login_screen.dart';

const _mint = Color(0xFF3DF59A);
const _green = Color(0xFF1FB86A);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  Timer? _timer;
  bool _done = false;

  /// Entrada (logo, texto) una sola vez.
  late final _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();

  /// Brillo del anillo y giro del indicador de carga (en bucle).
  late final _loop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2600), _go);
  }

  void _go() {
    _timer?.cancel();
    if (!mounted || _done) return;
    _done = true;
    // Si ya hay una sesión guardada (o se acaba de volver de Google), entra directo.
    final user = AuthService.currentUser;
    if (user != null) {
      enterApp(context, user);
    } else {
      Navigator.of(context).pushReplacement(fadeRoute(const LoginScreen()));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _intro.dispose();
    _loop.dispose();
    super.dispose();
  }

  /// Aparece con desplazamiento hacia arriba entre [from] y [to] (0..1).
  Widget _reveal(double from, double to, Widget child) {
    final a = CurvedAnimation(
      parent: _intro,
      curve: Interval(from, to, curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: a,
      builder: (_, c) => Opacity(
        opacity: a.value,
        child: Transform.translate(
          offset: Offset(0, 24 * (1 - a.value)),
          child: c,
        ),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF03140D),
    body: GestureDetector(
      onTap: _go,
      child: CustomPaint(
        painter: const _SplashBackground(),
        child: SafeArea(
          child: Align(
            alignment: const Alignment(0, -0.22),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _reveal(
                    0,
                    0.55,
                    ScaleTransition(
                      scale: CurvedAnimation(
                        parent: _intro,
                        curve: const Interval(
                          0,
                          0.6,
                          curve: Curves.easeOutBack,
                        ),
                      ),
                      child: _OrbitLogo(glow: _loop),
                    ),
                  ),
                  const SizedBox(height: 34),
                  _reveal(0.25, 0.75, const _Wordmark()),
                  const SizedBox(height: 18),
                  _reveal(
                    0.4,
                    0.9,
                    const Text.rich(
                      TextSpan(
                        text: 'Controla tus finanzas,\nconstruye tus ',
                        children: [
                          TextSpan(
                            text: 'sueños',
                            style: TextStyle(
                              color: _mint,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        height: 1.4,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 44),
                  _reveal(0.6, 1, _Loader(spin: _loop)),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/* ───────────── Logo con anillo en órbita ───────────── */

class _OrbitLogo extends StatelessWidget {
  final Animation<double> glow;
  const _OrbitLogo({required this.glow});

  static const _box = 150.0;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 290,
    height: 190,
    child: AnimatedBuilder(
      animation: glow,
      builder: (_, child) {
        final pulse = 0.5 + 0.5 * math.sin(glow.value * 2 * math.pi);
        return Stack(
          alignment: Alignment.center,
          children: [
            // Mitad trasera del anillo (detrás del cuadro)
            Positioned.fill(
              child: CustomPaint(
                painter: _RingPainter(back: true, pulse: pulse),
              ),
            ),
            child!,
            // Mitad delantera del anillo (pasa por encima del cuadro)
            Positioned.fill(
              child: CustomPaint(
                painter: _RingPainter(back: false, pulse: pulse),
              ),
            ),
          ],
        );
      },
      child: Container(
        width: _box,
        height: _box,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(38),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF22B573), Color(0xFF0E6B43), Color(0xFF0A4A30)],
          ),
          border: Border.all(color: _mint.withValues(alpha: 0.75), width: 2),
          boxShadow: [
            BoxShadow(
              color: _mint.withValues(alpha: 0.45),
              blurRadius: 36,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Reflejo de vidrio arriba
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(36),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.center,
                    colors: [
                      Colors.white.withValues(alpha: 0.18),
                      Colors.white.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 14),
                child: Image.asset(
                  'assets/images/logo_face.png',
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _RingPainter extends CustomPainter {
  final bool back;
  final double pulse;
  const _RingPainter({required this.back, required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    canvas
      ..save()
      ..translate(c.dx, c.dy + 8)
      ..rotate(-0.30);
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: size.width * 0.98,
      height: size.height * 0.36,
    );
    // Arriba = detrás, abajo = delante.
    final start = back ? math.pi : 0.0;
    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..color = _mint.withValues(alpha: 0.35 + 0.25 * pulse)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = back ? 2.2 : 3
      ..strokeCap = StrokeCap.round
      ..color = Color.lerp(_mint, Colors.white, back ? 0.1 : 0.45)!;
    canvas
      ..drawArc(rect, start, math.pi, false, glow)
      ..drawArc(rect, start, math.pi, false, line)
      ..restore();
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.pulse != pulse;
}

/* ───────────── "Finix" con acento verde ───────────── */

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      const Text(
        'Finix',
        style: TextStyle(
          color: Colors.white,
          fontSize: 76,
          fontWeight: FontWeight.w800,
          letterSpacing: -2,
          height: 1,
        ),
      ),
      Positioned(
        right: -6,
        top: -4,
        child: Transform.rotate(
          angle: -0.55,
          child: Container(
            width: 26,
            height: 10,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_green, _mint]),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
              boxShadow: [
                BoxShadow(color: _mint.withValues(alpha: 0.5), blurRadius: 8),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

/* ───────────── Indicador de carga ───────────── */

class _Loader extends StatelessWidget {
  final Animation<double> spin;
  const _Loader({required this.spin});

  Widget _line(bool left) => Container(
    width: 96,
    height: 1.2,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          _mint.withValues(alpha: left ? 0 : 0.45),
          _mint.withValues(alpha: left ? 0.45 : 0),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      _line(true),
      const SizedBox(width: 18),
      RotationTransition(
        turns: spin,
        child: const SizedBox(
          width: 36,
          height: 36,
          child: CustomPaint(painter: _SpinnerPainter()),
        ),
      ),
      const SizedBox(width: 18),
      _line(false),
    ],
  );
}

class _SpinnerPainter extends CustomPainter {
  const _SpinnerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = rect.deflate(2.5);
    canvas.drawArc(
      r,
      0,
      2 * math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = _green.withValues(alpha: 0.18),
    );
    canvas.drawArc(
      r,
      0,
      math.pi * 1.5,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          colors: [_green.withValues(alpha: 0), _mint],
          stops: const [0, 0.75],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/* ───────────── Fondo con ondas brillantes ───────────── */

class _SplashBackground extends CustomPainter {
  const _SplashBackground();

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    final full = Offset.zero & s;

    // Base oscura
    canvas.drawRect(
      full,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF052417), Color(0xFF03140D), Color(0xFF020C08)],
        ).createShader(full),
    );

    // Resplandores
    void radial(Offset c, double r, Color color) => canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    radial(Offset(w * 1.02, h * 0.14), w * 0.7, _green.withValues(alpha: 0.45));
    radial(Offset(w * 0.5, h * 0.42), w * 0.6, _green.withValues(alpha: 0.10));
    radial(Offset(w * 0.1, h * 0.85), w * 0.7, _green.withValues(alpha: 0.18));

    void glowLine(Path p, {double width = 2, double alpha = 1}) {
      canvas
        ..drawPath(
          p,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = width * 4
            ..color = _mint.withValues(alpha: 0.35 * alpha)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        )
        ..drawPath(
          p,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = width
            ..color = Color.lerp(
              _mint,
              Colors.white,
              0.35,
            )!.withValues(alpha: alpha),
        );
    }

    /* Onda superior izquierda */
    final topEdge = Path()
      ..moveTo(w * 0.56, -4)
      ..cubicTo(w * 0.42, h * 0.08, w * 0.3, h * 0.11, w * 0.12, h * 0.14)
      ..quadraticBezierTo(w * 0.04, h * 0.16, -4, h * 0.2);
    final topFill = Path.from(topEdge)
      ..lineTo(-4, -4)
      ..close();
    canvas.drawPath(
      topFill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            const Color(0xFF0F5C3A).withValues(alpha: 0.9),
            const Color(0xFF06291B).withValues(alpha: 0.6),
          ],
        ).createShader(full),
    );
    glowLine(topEdge, width: 2.2);
    glowLine(
      Path()
        ..moveTo(w * 0.32, -4)
        ..cubicTo(w * 0.22, h * 0.07, w * 0.12, h * 0.1, -4, h * 0.12),
      width: 1,
      alpha: 0.35,
    );

    /* Onda inferior */
    final upper = Path()
      ..moveTo(-4, h * 0.745)
      ..cubicTo(w * 0.18, h * 0.71, w * 0.32, h * 0.76, w * 0.5, h * 0.79)
      ..cubicTo(w * 0.7, h * 0.82, w * 0.85, h * 0.75, w + 4, h * 0.72);
    final main = Path()
      ..moveTo(-4, h * 0.75)
      ..cubicTo(w * 0.2, h * 0.73, w * 0.38, h * 0.82, w * 0.6, h * 0.87)
      ..cubicTo(w * 0.78, h * 0.91, w * 0.9, h * 0.9, w + 4, h * 0.88);

    // Banda verde entre las dos curvas
    final band = Path.from(upper)
      ..lineTo(w + 4, h * 0.88)
      ..cubicTo(w * 0.9, h * 0.9, w * 0.78, h * 0.91, w * 0.6, h * 0.87)
      ..cubicTo(w * 0.38, h * 0.82, w * 0.2, h * 0.73, -4, h * 0.75)
      ..close();
    canvas.drawPath(
      band,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1C9C60).withValues(alpha: 0.75),
            const Color(0xFF0B4A2F).withValues(alpha: 0.5),
          ],
        ).createShader(Rect.fromLTWH(0, h * 0.7, w, h * 0.22)),
    );

    // Barras de crecimiento (abajo a la derecha)
    for (var i = 0; i < 5; i++) {
      final bw = w * 0.05;
      final x = w * 0.7 + i * w * 0.065;
      final top = h * (0.83 - i * 0.03);
      final r = Rect.fromLTRB(x, top, x + bw, h * 0.95);
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          r,
          topLeft: const Radius.circular(5),
          topRight: const Radius.circular(5),
        ),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _green.withValues(alpha: 0.30 + i * 0.05),
              _green.withValues(alpha: 0),
            ],
          ).createShader(r),
      );
    }

    // Zona oscura bajo la curva principal
    final bottomFill = Path.from(main)
      ..lineTo(w + 4, h + 4)
      ..lineTo(-4, h + 4)
      ..close();
    canvas.drawPath(
      bottomFill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF06291B).withValues(alpha: 0.75),
            const Color(0xFF020C08),
          ],
        ).createShader(Rect.fromLTWH(0, h * 0.75, w, h * 0.25)),
    );
    glowLine(upper, width: 1, alpha: 0.4);
    glowLine(main, width: 2.6);
    glowLine(
      Path()
        ..moveTo(-4, h * 0.86)
        ..cubicTo(w * 0.3, h * 0.82, w * 0.55, h * 0.95, w + 4, h * 0.97),
      width: 1,
      alpha: 0.25,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
