import 'package:flutter/material.dart';
import 'package:pokedex/presentation/widgets/pokedex_top_cap.dart';

abstract final class PokedexDeviceColors {
  static const backgroundRed = Color(0xFFE21C26);
  static const frameGray = Color(0xFFD9D9D9);
  static const frameShadow = Color(0xFFB8B8B8);
  static const outline = Color(0xFF1F1F1F);
  static const screen = Color(0xFF2B2B2B);
  static const accentRed = Color(0xFFE21C26);
}

abstract final class PokedexDeviceLayout {
  static const topPadding = 80.0;
  static const horizontalPadding = 18.0;
  static const frameInset = 26.0;
  static const bottomButtonSize = 38.0;
  static const speakerWidthExtra = 10.0;
  static const speakerLineHeight = 4.0;
  static const speakerLineSpacing = 7.0;
}

class PokedexFrameClipper extends CustomClipper<Path> {
  const PokedexFrameClipper({
    this.radius = 18,
    this.chamfer = 42,
  });

  final double radius;
  final double chamfer;

  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(radius, 0)
      ..lineTo(size.width - radius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, radius)
      ..lineTo(size.width, size.height - radius)
      ..quadraticBezierTo(
        size.width,
        size.height,
        size.width - radius,
        size.height,
      )
      ..lineTo(chamfer, size.height)
      ..lineTo(0, size.height - chamfer)
      ..lineTo(0, radius)
      ..quadraticBezierTo(0, 0, radius, 0)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant PokedexFrameClipper oldClipper) {
    return radius != oldClipper.radius || chamfer != oldClipper.chamfer;
  }
}

class PokedexDeviceHeader extends StatelessWidget {
  const PokedexDeviceHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final deviceHeight = width * 0.92;

    return ColoredBox(
      color: PokedexDeviceColors.backgroundRed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: PokedexDeviceLayout.topPadding),
            child: PokedexTopCap(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              PokedexDeviceLayout.horizontalPadding,
              6,
              PokedexDeviceLayout.horizontalPadding,
              12,
            ),
            child: SizedBox(
              height: deviceHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 5,
                    top: 5,
                    right: 0,
                    bottom: 0,
                    child: _PokedexFrame(
                      fillColor: PokedexDeviceColors.frameShadow,
                      showDetails: false,
                    ),
                  ),
                  Positioned.fill(
                    child: _PokedexFrame(
                      fillColor: PokedexDeviceColors.frameGray,
                      showDetails: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PokedexFrame extends StatelessWidget {
  const _PokedexFrame({
    required this.fillColor,
    required this.showDetails,
  });

  final Color fillColor;
  final bool showDetails;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: const PokedexFrameClipper(),
      child: CustomPaint(
        painter: _PokedexFramePainter(fillColor: fillColor),
        child: showDetails
            ? LayoutBuilder(
                builder: (context, constraints) {
                  final inset = PokedexDeviceLayout.frameInset;
                  final screenTop = inset + 14 + 12;
                  final screenHeight = constraints.maxHeight * 0.52 + 30;

                  return Stack(
                    children: [
                      Positioned(
                        top: inset,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            _IndicatorLight(size: 14),
                            SizedBox(width: 18),
                            _IndicatorLight(size: 14),
                          ],
                        ),
                      ),
                      Positioned(
                        left: inset,
                        right: inset,
                        top: screenTop,
                        height: screenHeight,
                        child: Container(
                          decoration: BoxDecoration(
                            color: PokedexDeviceColors.screen,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: PokedexDeviceColors.outline,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const Positioned(
                        left: PokedexDeviceLayout.frameInset,
                        bottom: PokedexDeviceLayout.frameInset,
                        child: _IndicatorLight(
                          size: PokedexDeviceLayout.bottomButtonSize,
                        ),
                      ),
                      Positioned(
                        right: PokedexDeviceLayout.frameInset,
                        bottom: PokedexDeviceLayout.frameInset,
                        child: _SpeakerGrille(
                          width: constraints.maxWidth * 0.16 +
                              PokedexDeviceLayout.speakerWidthExtra,
                        ),
                      ),
                    ],
                  );
                },
              )
            : const SizedBox.expand(),
      ),
    );
  }
}

class _PokedexFramePainter extends CustomPainter {
  const _PokedexFramePainter({required this.fillColor});

  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    final clipper = PokedexFrameClipper();
    final path = clipper.getClip(size);

    final fillPaint = Paint()..color = fillColor;
    canvas.drawPath(path, fillPaint);

    final borderPaint = Paint()
      ..color = PokedexDeviceColors.outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _PokedexFramePainter oldDelegate) {
    return fillColor != oldDelegate.fillColor;
  }
}

class _IndicatorLight extends StatelessWidget {
  const _IndicatorLight({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: PokedexDeviceColors.accentRed,
        border: Border.all(
          color: PokedexDeviceColors.outline,
          width: 2,
        ),
      ),
    );
  }
}

class _SpeakerGrille extends StatelessWidget {
  const _SpeakerGrille({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(4, (index) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: index == 3 ? 0 : PokedexDeviceLayout.speakerLineSpacing,
            ),
            child: Container(
              height: PokedexDeviceLayout.speakerLineHeight,
              decoration: BoxDecoration(
                color: PokedexDeviceColors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}
