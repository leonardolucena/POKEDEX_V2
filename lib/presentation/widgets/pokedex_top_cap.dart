import 'dart:math' as math;

import 'package:flutter/material.dart';

abstract final class PokedexTopCapColors {
  static const outline = Color(0xFF230B2D);
  static const lensBlue = Color(0xFF00D4FF);
  static const lensRingGreen = Color(0xFFA6E0DB);
  static const ledRed = Color(0xFFFF2D2D);
  static const ledYellow = Color(0xFFFFD400);
  static const ledGreen = Color(0xFF3DDC4A);
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
                    color: PokedexTopCapColors.ledRed,
                    size: 18,
                  ),
                  SizedBox(width: 10),
                  PokedexStatusLed(
                    color: PokedexTopCapColors.ledYellow,
                    size: 18,
                  ),
                  SizedBox(width: 10),
                  PokedexStatusLed(
                    color: PokedexTopCapColors.ledGreen,
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

class PokedexLens extends StatelessWidget {
  const PokedexLens({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final innerSize = size * 0.62;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: const _LensRingPainter(),
          ),
          Container(
            width: innerSize,
            height: innerSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                center: Alignment(-0.25, -0.35),
                radius: 0.95,
                colors: [
                  Color(0xFF7DEBFF),
                  PokedexTopCapColors.lensBlue,
                  Color(0xFF00A8CC),
                ],
                stops: [0.1, 0.55, 1],
              ),
              border: Border.all(
                color: PokedexTopCapColors.outline,
                width: 2.5,
              ),
            ),
            child: Align(
              alignment: const Alignment(0.35, -0.35),
              child: Container(
                width: innerSize * 0.22,
                height: innerSize * 0.22,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
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

class PokedexStatusLed extends StatelessWidget {
  const PokedexStatusLed({
    super.key,
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(
                color: PokedexTopCapColors.outline,
                width: 2,
              ),
            ),
          ),
          Positioned(
            top: size * 0.18,
            left: size * 0.22,
            child: Container(
              width: size * 0.22,
              height: size * 0.22,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
