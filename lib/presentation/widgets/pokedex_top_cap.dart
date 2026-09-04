import 'dart:math' as math;

import 'package:flutter/material.dart';

abstract final class PokedexTopCapColors {
  static const outline = Color(0xFF230B2D);
  static const lensBlue = Color(0xFF00D4FF);
  static const lensBlueHighlight = Color(0xFF66E8FF);
  static const lensBlueMid = Color(0xFF00C8F0);
  static const lensBlueGlow = Color(0xFF7DEBFF);
  static const lensBlueNeon = Color(0xFF00FFFF);
  static const lensBlueShadow = Color(0xFF008FB0);
  static const lensBlueDeepShadow = Color(0xFF006A85);
  static const lensRingGreen = Color(0xFFA6E0DB);
  static const ledRed = Color(0xFFFF2D2D);
  static const ledRedHighlight = Color(0xFFFF6B6B);
  static const ledRedMid = Color(0xFFFF2D2D);
  static const ledRedShadow = Color(0xFFD41F1F);
  static const ledRedDeepShadow = Color(0xFFA81818);
  static const ledYellow = Color(0xFFFFD400);
  static const ledYellowHighlight = Color(0xFFFFEC80);
  static const ledYellowMid = Color(0xFFFFD400);
  static const ledYellowShadow = Color(0xFFE6BE00);
  static const ledYellowDeepShadow = Color(0xFFCCAA00);
  static const ledGreen = Color(0xFF3DDC4A);
  static const ledGreenHighlight = Color(0xFF72F07C);
  static const ledGreenMid = Color(0xFF3DDC4A);
  static const ledGreenShadow = Color(0xFF2AB535);
  static const ledGreenDeepShadow = Color(0xFF1E8F28);
}

enum PokedexLedTone { red, yellow, green }

extension PokedexLedToneColors on PokedexLedTone {
  (Color highlight, Color mid, Color shadow, Color deepShadow) get colors {
    return switch (this) {
      PokedexLedTone.red => (
          PokedexTopCapColors.ledRedHighlight,
          PokedexTopCapColors.ledRedMid,
          PokedexTopCapColors.ledRedShadow,
          PokedexTopCapColors.ledRedDeepShadow,
        ),
      PokedexLedTone.yellow => (
          PokedexTopCapColors.ledYellowHighlight,
          PokedexTopCapColors.ledYellowMid,
          PokedexTopCapColors.ledYellowShadow,
          PokedexTopCapColors.ledYellowDeepShadow,
        ),
      PokedexLedTone.green => (
          PokedexTopCapColors.ledGreenHighlight,
          PokedexTopCapColors.ledGreenMid,
          PokedexTopCapColors.ledGreenShadow,
          PokedexTopCapColors.ledGreenDeepShadow,
        ),
    };
  }
}

abstract final class PokedexTopCapLayout {
  static const horizontalInset = 18.0;
  static const lensBottomPadding = 16.0;
}

class PokedexTopCap extends StatelessWidget {
  const PokedexTopCap({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = width * 0.28;
    final lineYLeft = height * 0.92;
    final lensSize = math.min(
      height * 0.88,
      lineYLeft - PokedexTopCapLayout.lensBottomPadding,
    );

    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: const PokedexTopCapPainter(),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: PokedexTopCapLayout.horizontalInset,
              bottom: height - lineYLeft + PokedexTopCapLayout.lensBottomPadding,
              child: PokedexLens(size: lensSize),
            ),
            Positioned(
              top: 4,
              right: PokedexTopCapLayout.horizontalInset,
              child: Row(
                children: const [
                  PokedexStatusLed(
                    tone: PokedexLedTone.red,
                    size: 18,
                  ),
                  SizedBox(width: 10),
                  PokedexStatusLed(
                    tone: PokedexLedTone.yellow,
                    size: 18,
                  ),
                  SizedBox(width: 10),
                  PokedexStatusLed(
                    tone: PokedexLedTone.green,
                    size: 18,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class PokedexTopCapPainter extends CustomPainter {
  const PokedexTopCapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const lineStroke = 4.5;

    final lineYLeft = size.height * 0.92;
    final diagonalStartX = size.width * 0.52;
    final diagonalLength = size.width * 0.14;
    final lineYRight = lineYLeft - diagonalLength;
    final diagonalEndX = diagonalStartX + diagonalLength;

    final linePath = Path()
      ..moveTo(0, lineYLeft)
      ..lineTo(diagonalStartX, lineYLeft)
      ..lineTo(diagonalEndX, lineYRight)
      ..lineTo(size.width, lineYRight);

    canvas.drawPath(
      linePath,
      Paint()
        ..color = PokedexTopCapColors.outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = lineStroke
        ..strokeCap = StrokeCap.square
        ..strokeJoin = StrokeJoin.miter,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PokedexLens extends StatefulWidget {
  const PokedexLens({super.key, required this.size});

  final double size;

  @override
  State<PokedexLens> createState() => _PokedexLensState();
}

class _PokedexLensState extends State<PokedexLens>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late final AnimationController _pulseController;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulse = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final innerSize = size * 0.62;
    final pressOffset = _pressed ? const Offset(1, 1.5) : Offset.zero;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      behavior: HitTestBehavior.opaque,
      child: Transform.translate(
        offset: pressOffset,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 70),
          curve: Curves.easeOut,
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: _pressed
                ? const []
                : const [
                    BoxShadow(
                      color: Color(0x66000000),
                      offset: Offset(3, 4),
                      blurRadius: 3,
                    ),
                    BoxShadow(
                      color: Color(0x44000000),
                      offset: Offset(1.5, 2),
                      blurRadius: 0,
                    ),
                  ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: const _LensRingPainter(),
              ),
              AnimatedBuilder(
                animation: _pulse,
                builder: (context, child) {
                  final pulse = _pressed ? 0.0 : _pulse.value;

                  return Container(
                    width: innerSize,
                    height: innerSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _pressed
                            ? const [
                                PokedexTopCapColors.lensBlueMid,
                                PokedexTopCapColors.lensBlue,
                                PokedexTopCapColors.lensBlueDeepShadow,
                              ]
                            : [
                                Color.lerp(
                                  PokedexTopCapColors.lensBlueHighlight,
                                  PokedexTopCapColors.lensBlueNeon,
                                  pulse * 0.85,
                                )!,
                                Color.lerp(
                                  PokedexTopCapColors.lensBlueMid,
                                  PokedexTopCapColors.lensBlueNeon,
                                  pulse,
                                )!,
                                Color.lerp(
                                  PokedexTopCapColors.lensBlueShadow,
                                  PokedexTopCapColors.lensBlue,
                                  pulse * 0.45,
                                )!,
                              ],
                      ),
                      border: Border.all(
                        color: PokedexTopCapColors.outline,
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: PokedexTopCapColors.lensBlueNeon
                              .withValues(alpha: 0.18 + pulse * 0.62),
                          blurRadius: 8 + pulse * 16,
                          spreadRadius: pulse * 2.5,
                        ),
                      ],
                    ),
                    child: child,
                  );
                },
                child: ClipOval(
                  child: Stack(
                    children: [
                      AnimatedBuilder(
                        animation: _pulse,
                        builder: (context, _) {
                          final pulse = _pressed ? 0.0 : _pulse.value;
                          return Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  center: const Alignment(-0.25, -0.35),
                                  radius: 0.95,
                                  colors: [
                                    Color.lerp(
                                      PokedexTopCapColors.lensBlueGlow,
                                      PokedexTopCapColors.lensBlueNeon,
                                      pulse,
                                    )!,
                                    Colors.transparent,
                                  ],
                                  stops: [0.08 + pulse * 0.08, 0.78],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      if (!_pressed)
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.center,
                                colors: [
                                  Colors.white.withValues(alpha: 0.28),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (!_pressed)
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomRight,
                                end: Alignment.center,
                                colors: [
                                  Colors.black.withValues(alpha: 0.2),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      Align(
                        alignment: const Alignment(0.35, -0.35),
                        child: AnimatedBuilder(
                          animation: _pulse,
                          builder: (context, _) {
                            final pulse = _pressed ? 0.0 : _pulse.value;
                            return Container(
                              width: innerSize * 0.22,
                              height: innerSize * 0.22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color.lerp(
                                  Colors.white,
                                  PokedexTopCapColors.lensBlueNeon,
                                  pulse * 0.35,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LensRingPainter extends CustomPainter {
  const _LensRingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final ringWidth = size.width * 0.11;

    final ringRect = Rect.fromCircle(center: center, radius: radius - ringWidth / 2);

    canvas.drawCircle(
      center,
      radius - ringWidth / 2,
      Paint()
        ..color = PokedexTopCapColors.outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringWidth + 2.5,
    );

    canvas.drawArc(
      ringRect,
      math.pi,
      math.pi,
      true,
      Paint()
        ..color = PokedexTopCapColors.lensRingGreen
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringWidth,
    );

    canvas.drawArc(
      ringRect,
      0,
      math.pi,
      true,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringWidth,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PokedexStatusLed extends StatefulWidget {
  const PokedexStatusLed({
    super.key,
    required this.tone,
    required this.size,
  });

  final PokedexLedTone tone;
  final double size;

  @override
  State<PokedexStatusLed> createState() => _PokedexStatusLedState();
}

class _PokedexStatusLedState extends State<PokedexStatusLed> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = widget.tone.colors;
    final pressOffset = _pressed ? const Offset(0.8, 1.2) : Offset.zero;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      behavior: HitTestBehavior.opaque,
      child: Transform.translate(
        offset: pressOffset,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 70),
          curve: Curves.easeOut,
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _pressed
                  ? [colors.$2, colors.$2, colors.$4]
                  : [colors.$1, colors.$2, colors.$3],
            ),
            border: Border.all(
              color: PokedexTopCapColors.outline,
              width: 2,
            ),
            boxShadow: _pressed
                ? const []
                : const [
                    BoxShadow(
                      color: Color(0x66000000),
                      offset: Offset(2, 2.5),
                      blurRadius: 2,
                    ),
                    BoxShadow(
                      color: Color(0x44000000),
                      offset: Offset(1, 1.5),
                      blurRadius: 0,
                    ),
                  ],
          ),
          child: ClipOval(
            child: Stack(
              children: [
                if (!_pressed)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.center,
                          colors: [
                            Colors.white.withValues(alpha: 0.26),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                if (!_pressed)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomRight,
                          end: Alignment.center,
                          colors: [
                            Colors.black.withValues(alpha: 0.18),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: widget.size * 0.18,
                  left: widget.size * 0.22,
                  child: Container(
                    width: widget.size * 0.22,
                    height: widget.size * 0.22,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
