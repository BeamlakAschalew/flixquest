import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/occasional_theme.dart';

/// A non-interactive, vector-only seasonal effect rendered over app pages.
/// Particle counts are capped by configuration parsing and animations stop
/// when the app is backgrounded or reduced motion is enabled.
class OccasionalEffectOverlay extends StatefulWidget {
  const OccasionalEffectOverlay({
    required this.theme,
    required this.enabled,
    super.key,
  });

  final OccasionalTheme? theme;
  final bool enabled;

  @override
  State<OccasionalEffectOverlay> createState() =>
      _OccasionalEffectOverlayState();
}

class _OccasionalEffectOverlayState extends State<OccasionalEffectOverlay>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _controller;
  bool _appActive = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appActive = state == AppLifecycleState.resumed;
    _syncAnimation();
  }

  @override
  void didUpdateWidget(OccasionalEffectOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAnimation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  void _syncAnimation() {
    if (!mounted) return;
    final media = MediaQuery.maybeOf(context);
    final reduceMotion =
        media?.disableAnimations == true || media?.accessibleNavigation == true;
    final effect = widget.theme?.effect;
    final shouldRun = widget.enabled &&
        _appActive &&
        !reduceMotion &&
        effect?.enabled == true &&
        effect?.type != OccasionalEffectType.none;
    if (shouldRun && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!shouldRun && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    if (!widget.enabled || theme == null || !theme.effect.enabled) {
      return const SizedBox.shrink();
    }
    final media = MediaQuery.of(context);
    if (media.disableAnimations || media.accessibleNavigation) {
      return const SizedBox.shrink();
    }
    return ExcludeSemantics(
      child: IgnorePointer(
        child: RepaintBoundary(
          child: CustomPaint(
            key: const Key('occasional-effect-canvas'),
            painter: _OccasionalEffectPainter(
              animation: _controller,
              effect: theme.effect,
              primary: theme.primaryColor,
              secondary: theme.secondaryColor,
              tertiary: theme.tertiaryColor,
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }
}

class _OccasionalEffectPainter extends CustomPainter {
  _OccasionalEffectPainter({
    required Animation<double> animation,
    required this.effect,
    required this.primary,
    required this.secondary,
    required this.tertiary,
  })  : _animation = animation,
        super(repaint: animation);

  final Animation<double> _animation;
  final OccasionalEffect effect;
  final Color primary;
  final Color secondary;
  final Color tertiary;

  double get _time => _animation.value * effect.speed;

  List<Color> get _colors => effect.colors.isNotEmpty
      ? effect.colors
      : switch (effect.type) {
          OccasionalEffectType.snow => const <Color>[
              Color(0xFFFFFFFF),
              Color(0xFFDCEEFF),
              Color(0xFFEAF7FF),
            ],
          OccasionalEffectType.fireworks ||
          OccasionalEffectType.confetti ||
          OccasionalEffectType.sparkles =>
            <Color>[
              primary,
              secondary,
              tertiary,
              const Color(0xFFFFD54F),
              const Color(0xFF80D8FF),
            ],
          OccasionalEffectType.petals => <Color>[
              primary,
              secondary,
              tertiary,
              const Color(0xFFFFD740),
            ],
          OccasionalEffectType.hearts => <Color>[
              primary,
              secondary,
              tertiary,
              const Color(0xFFFF80AB),
            ],
          OccasionalEffectType.stars => <Color>[
              primary,
              secondary,
              tertiary,
              const Color(0xFFFFD54F),
            ],
          OccasionalEffectType.bats => <Color>[
              primary,
              secondary,
              const Color(0xFF202020),
            ],
          OccasionalEffectType.none => const <Color>[],
        };

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    switch (effect.type) {
      case OccasionalEffectType.snow:
        _paintSnow(canvas, size);
      case OccasionalEffectType.confetti:
        _paintConfetti(canvas, size);
      case OccasionalEffectType.fireworks:
        _paintFireworks(canvas, size);
      case OccasionalEffectType.petals:
        _paintPetals(canvas, size);
      case OccasionalEffectType.hearts:
        _paintHearts(canvas, size);
      case OccasionalEffectType.stars:
        _paintStars(canvas, size);
      case OccasionalEffectType.bats:
        _paintBats(canvas, size);
      case OccasionalEffectType.sparkles:
        _paintSparkles(canvas, size);
      case OccasionalEffectType.none:
        break;
    }
  }

  void _paintSnow(Canvas canvas, Size size) {
    for (var i = 0; i < effect.density; i++) {
      final depth = .45 + _unit(i * 11 + 2) * .8;
      final y = _wrap(_unit(i * 31 + 5) + _time * .26 * depth);
      final drift = math.sin((_time * 2 + i) * math.pi) * 18 * depth;
      final x = _unit(i * 19 + 9) * size.width + drift;
      final radius = 1.7 + 3.2 * depth;
      final color = _color(i, (.28 + .5 * depth) * effect.opacity);
      final paint = Paint()
        ..color = color
        ..strokeWidth = math.max(1, radius * .24)
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final center = Offset(x, y * size.height);
      if (i % 4 == 0) {
        for (var arm = 0; arm < 3; arm++) {
          final angle = arm * math.pi / 3;
          final vector = Offset(math.cos(angle), math.sin(angle)) * radius;
          canvas.drawLine(center - vector, center + vector, paint);
        }
      } else {
        canvas.drawCircle(
            center, radius * .42, paint..style = PaintingStyle.fill);
      }
    }
  }

  void _paintConfetti(Canvas canvas, Size size) {
    for (var i = 0; i < effect.density; i++) {
      final y = _wrap(_unit(i * 29 + 4) + _time * (.22 + _unit(i) * .2));
      final x = _unit(i * 17 + 3) * size.width +
          math.sin((_time + i) * math.pi * 2) * 14;
      final paint = Paint()..color = _color(i, effect.opacity * .72);
      canvas.save();
      canvas.translate(x, y * size.height);
      canvas.rotate((_time * 5 + i) * math.pi / 3);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: 4, height: 10),
          const Radius.circular(1.5),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  void _paintFireworks(Canvas canvas, Size size) {
    final count = effect.density.clamp(4, 18);
    for (var i = 0; i < count; i++) {
      final phase = _wrap(_time * .72 + _unit(i * 23));
      if (phase > .72) continue;
      final burst = Curves.easeOut.transform((phase / .72).clamp(0, 1));
      final fade = (1 - phase / .72) * effect.opacity;
      final center = Offset(
        (.12 + _unit(i * 13) * .76) * size.width,
        (.1 + _unit(i * 37 + 8) * .52) * size.height,
      );
      final paint = Paint()
        ..color = _color(i, fade)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;
      final radius = 18 + burst * (28 + _unit(i * 7) * 42);
      for (var ray = 0; ray < 12; ray++) {
        final angle = ray * math.pi / 6 + _unit(i) * math.pi;
        final direction = Offset(math.cos(angle), math.sin(angle));
        canvas.drawLine(
          center + direction * radius * .68,
          center + direction * radius,
          paint,
        );
      }
    }
  }

  void _paintPetals(Canvas canvas, Size size) {
    for (var i = 0; i < effect.density; i++) {
      final y = _wrap(_unit(i * 41 + 1) + _time * (.15 + _unit(i) * .16));
      final x = _unit(i * 17 + 7) * size.width +
          math.sin((_time + i * .3) * math.pi * 2) * 24;
      final scale = .65 + _unit(i * 5) * .75;
      final path = Path()
        ..moveTo(0, -7 * scale)
        ..quadraticBezierTo(7 * scale, -2 * scale, 0, 8 * scale)
        ..quadraticBezierTo(-7 * scale, -2 * scale, 0, -7 * scale)
        ..close();
      canvas.save();
      canvas.translate(x, y * size.height);
      canvas.rotate((_time * 2 + i) * math.pi);
      canvas.drawPath(path, Paint()..color = _color(i, effect.opacity * .55));
      canvas.restore();
    }
  }

  void _paintHearts(Canvas canvas, Size size) {
    for (var i = 0; i < effect.density; i++) {
      final progress = _wrap(_unit(i * 31) + _time * (.1 + _unit(i) * .12));
      final y = size.height * (1.08 - progress * 1.18);
      final x = _unit(i * 13 + 4) * size.width +
          math.sin((_time + i) * math.pi * 2) * 20;
      final scale = .45 + _unit(i * 7) * .55;
      canvas.save();
      canvas.translate(x, y);
      canvas.scale(scale);
      canvas.drawPath(
        _heartPath(),
        Paint()..color = _color(i, effect.opacity * .48),
      );
      canvas.restore();
    }
  }

  void _paintStars(Canvas canvas, Size size) {
    for (var i = 0; i < effect.density; i++) {
      final x = _unit(i * 19 + 2) * size.width;
      final y = _unit(i * 43 + 6) * size.height * .82;
      final twinkle = .25 + .75 * (math.sin((_time * 4 + i) * math.pi) + 1) / 2;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(_time + i);
      canvas.drawPath(
        _starPath(3 + _unit(i) * 4),
        Paint()..color = _color(i, effect.opacity * twinkle * .62),
      );
      canvas.restore();
    }
  }

  void _paintBats(Canvas canvas, Size size) {
    for (var i = 0; i < effect.density; i++) {
      final x = _wrap(_unit(i * 29) + _time * (.12 + _unit(i) * .13));
      final y = (.08 + _unit(i * 17) * .72) * size.height +
          math.sin((_time + i) * math.pi * 2) * 12;
      final scale = .5 + _unit(i * 7) * .7;
      canvas.save();
      canvas.translate(x * size.width, y);
      canvas.scale(scale);
      canvas.drawPath(
        _batPath(math.sin((_time * 8 + i) * math.pi) * 2),
        Paint()..color = _color(i, effect.opacity * .48),
      );
      canvas.restore();
    }
  }

  void _paintSparkles(Canvas canvas, Size size) {
    for (var i = 0; i < effect.density; i++) {
      final x = _unit(i * 23 + 3) * size.width;
      final y = _unit(i * 47 + 9) * size.height;
      final pulse = (math.sin((_time * 5 + i) * math.pi) + 1) / 2;
      final radius = 2 + pulse * 7;
      final paint = Paint()
        ..color = _color(i, effect.opacity * (.18 + pulse * .58))
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(x - radius, y), Offset(x + radius, y), paint);
      canvas.drawLine(Offset(x, y - radius), Offset(x, y + radius), paint);
      if (i.isEven) {
        canvas.drawCircle(Offset(x, y), radius * .22, paint);
      }
    }
  }

  Color _color(int index, double opacity) =>
      _colors[index % _colors.length].withValues(alpha: opacity.clamp(0, 1));

  static double _wrap(double value) => value - value.floorToDouble();

  static double _unit(int seed) {
    final value = math.sin(seed * 12.9898 + 78.233) * 43758.5453;
    return (value - value.floorToDouble()).abs();
  }

  static Path _heartPath() => Path()
    ..moveTo(0, 11)
    ..cubicTo(-18, 0, -13, -13, -5, -10)
    ..cubicTo(-2, -9, 0, -6, 0, -4)
    ..cubicTo(0, -6, 2, -9, 5, -10)
    ..cubicTo(13, -13, 18, 0, 0, 11)
    ..close();

  static Path _starPath(double radius) {
    final path = Path();
    for (var point = 0; point < 10; point++) {
      final angle = -math.pi / 2 + point * math.pi / 5;
      final r = point.isEven ? radius : radius * .42;
      final offset = Offset(math.cos(angle) * r, math.sin(angle) * r);
      if (point == 0) {
        path.moveTo(offset.dx, offset.dy);
      } else {
        path.lineTo(offset.dx, offset.dy);
      }
    }
    return path..close();
  }

  static Path _batPath(double flap) => Path()
    ..moveTo(0, 2)
    ..quadraticBezierTo(-7, -7 - flap, -16, -3)
    ..quadraticBezierTo(-12, 2, -9, 5)
    ..quadraticBezierTo(-5, 1, 0, 6)
    ..quadraticBezierTo(5, 1, 9, 5)
    ..quadraticBezierTo(12, 2, 16, -3)
    ..quadraticBezierTo(7, -7 - flap, 0, 2)
    ..close();

  @override
  bool shouldRepaint(_OccasionalEffectPainter oldDelegate) =>
      oldDelegate.effect != effect ||
      oldDelegate.primary != primary ||
      oldDelegate.secondary != secondary ||
      oldDelegate.tertiary != tertiary;
}
