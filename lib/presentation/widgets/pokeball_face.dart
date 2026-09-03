import 'package:flutter/material.dart';

abstract final class PokeballColors {
  static const red = Color(0xFFDC0A2D);
  static const white = Color(0xFFF0F0F0);
  static const buttonGray = Color(0xFFBDBDBD);
}

abstract final class PokeballLayout {
  static double buttonSize(Size size) => size.width * 0.45;

  static double seamHeight(Size size) => size.width * 0.028;
}

class PokeballTopHalf extends StatelessWidget {
  const PokeballTopHalf({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final buttonSize = PokeballLayout.buttonSize(size);
    final seamHeight = PokeballLayout.seamHeight(size);
    final halfHeight = size.height / 2;

    return SizedBox(
      width: size.width,
      height: halfHeight,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          const Positioned.fill(child: ColoredBox(color: PokeballColors.red)),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: seamHeight,
            child: const ColoredBox(color: Colors.black),
          ),
          Positioned(
            bottom: -(buttonSize / 2),
            left: size.width / 2 - buttonSize / 2,
            child: PokeballCenterButton(size: buttonSize),
          ),
        ],
      ),
    );
  }
}

class PokeballBottomHalf extends StatelessWidget {
  const PokeballBottomHalf({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final buttonSize = PokeballLayout.buttonSize(size);
    final seamHeight = PokeballLayout.seamHeight(size);
    final halfHeight = size.height / 2;

    return SizedBox(
      width: size.width,
      height: halfHeight,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          const Positioned.fill(child: ColoredBox(color: PokeballColors.white)),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: seamHeight,
            child: const ColoredBox(color: Colors.black),
          ),
          Positioned(
            top: -(buttonSize / 2),
            left: size.width / 2 - buttonSize / 2,
            child: PokeballCenterButton(size: buttonSize),
          ),
        ],
      ),
    );
  }
}

class PokeballCenterButton extends StatelessWidget {
  const PokeballCenterButton({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Colors.black, width: size * 0.08),
      ),
      child: Center(
        child: Container(
          width: size * 0.55,
          height: size * 0.55,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: PokeballColors.buttonGray,
              width: size * 0.04,
            ),
          ),
          child: Center(
            child: Container(
              width: size * 0.28,
              height: size * 0.28,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
