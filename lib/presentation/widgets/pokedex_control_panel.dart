import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex/providers/pokemon_providers.dart';

abstract final class PokedexControlPanelColors {
  static const outline = Color(0xFF1F1F1F);
  static const actionBlue = Color(0xFF00D4FF);
  static const pillGreen = Color(0xFF3DDC4A);
  static const pillOrange = Color(0xFFFF8A65);
  static const displayYellow = Color(0xFFFFD400);
  static const dpadNavy = Color(0xFF1B2A4E);
  static const dpadShadow = Color(0xFF0F1A33);
  static const dpadArrow = Color(0xFF4A5F8C);
}

abstract final class PokedexControlPanelLayout {
  static const horizontalPadding = 18.0;
  static const verticalPadding = 16.0;
}

class PokedexControlPanel extends ConsumerWidget {
  const PokedexControlPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(pokedexNavigationProvider);
    final listState = ref.watch(pokemonListNotifierProvider);
    final displayName = _pokemonDisplayName(listState, selectedIndex);
    final width = MediaQuery.sizeOf(context).width;
    final panelHeight = width * 0.34;
    final blueButtonSize = width * 0.15;
    final dpadSize = width * 0.34;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PokedexControlPanelLayout.horizontalPadding,
        PokedexControlPanelLayout.verticalPadding,
        PokedexControlPanelLayout.horizontalPadding,
        0,
      ),
      child: SizedBox(
        height: panelHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      _ActionBlueButton(size: blueButtonSize),
                      const SizedBox(width: 10),
                      const _StatusPill(color: PokedexControlPanelColors.pillGreen),
                      const SizedBox(width: 8),
                      const _StatusPill(color: PokedexControlPanelColors.pillOrange),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _YellowDisplayCard(label: displayName),
                ],
              ),
            ),
            const SizedBox(width: 16),
            PokedexDpad(
              size: dpadSize,
              onUp: ref.read(pokedexNavigationProvider.notifier).scrollDescriptionUp,
              onDown:
                  ref.read(pokedexNavigationProvider.notifier).scrollDescriptionDown,
              onLeft: ref.read(pokedexNavigationProvider.notifier).selectPrevious,
              onRight: () =>
                  ref.read(pokedexNavigationProvider.notifier).selectNext(),
            ),
          ],
        ),
      ),
    );
  }
}

String _pokemonDisplayName(PokemonListState listState, int selectedIndex) {
  if (listState.items.isEmpty) return '';

  final safeIndex = selectedIndex.clamp(0, listState.items.length - 1);
  final name = listState.items[safeIndex].name;

  return name
      .split('-')
      .map(
        (part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1)}',
      )
      .join('-');
}

class _ActionBlueButton extends StatelessWidget {
  const _ActionBlueButton({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: PokedexControlPanelColors.actionBlue,
        border: Border.all(
          color: PokedexControlPanelColors.outline,
          width: 2.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            offset: Offset(0, 2),
            blurRadius: 0,
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 59,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: PokedexControlPanelColors.outline,
          width: 2,
        ),
      ),
    );
  }
}

class _YellowDisplayCard extends StatelessWidget {
  const _YellowDisplayCard({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: PokedexControlPanelColors.displayYellow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: PokedexControlPanelColors.outline,
          width: 2.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            offset: Offset(0, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: const TextStyle(
            color: PokedexControlPanelColors.outline,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class PokedexDpad extends StatelessWidget {
  const PokedexDpad({
    super.key,
    required this.size,
    this.onUp,
    this.onDown,
    this.onLeft,
    this.onRight,
  });

  final double size;
  final VoidCallback? onUp;
  final VoidCallback? onDown;
  final VoidCallback? onLeft;
  final VoidCallback? onRight;

  @override
  Widget build(BuildContext context) {
    final arm = size * 0.34;
    final radius = size * 0.08;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.translate(
            offset: const Offset(2, 3),
            child: _DpadShape(
              size: size,
              arm: arm,
              radius: radius,
              fillColor: PokedexControlPanelColors.dpadShadow,
              showBorder: false,
            ),
          ),
          _DpadShape(
            size: size,
            arm: arm,
            radius: radius,
            fillColor: PokedexControlPanelColors.dpadNavy,
            showBorder: true,
          ),
          ..._buildArrows(size, arm),
          Container(
            width: size * 0.11,
            height: size * 0.11,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF2A3D66),
              border: Border.all(
                color: PokedexControlPanelColors.outline,
                width: 2,
              ),
            ),
          ),
          ..._buildTapTargets(size, arm),
        ],
      ),
    );
  }

  List<Widget> _buildArrows(double size, double arm) {
    final arrowSize = size * 0.24;
    final center = size / 2;
    final armHalf = arm / 2;

    final upCenterY = (center - armHalf) / 2;
    final downCenterY = (center + armHalf + size) / 2;
    final leftCenterX = (center - armHalf) / 2;
    final rightCenterX = (center + armHalf + size) / 2;

    Widget arrow({
      required double x,
      required double y,
      required IconData icon,
    }) {
      return Positioned(
        left: x - arrowSize / 2,
        top: y - arrowSize / 2,
        child: Icon(
          icon,
          size: arrowSize,
          color: PokedexControlPanelColors.dpadArrow,
        ),
      );
    }

    return [
      arrow(x: center, y: upCenterY, icon: Icons.keyboard_arrow_up),
      arrow(x: center, y: downCenterY, icon: Icons.keyboard_arrow_down),
      arrow(x: leftCenterX, y: center, icon: Icons.keyboard_arrow_left),
      arrow(x: rightCenterX, y: center, icon: Icons.keyboard_arrow_right),
    ];
  }

  List<Widget> _buildTapTargets(double size, double arm) {
    final center = size / 2;
    final armHalf = arm / 2;

    Widget target({
      required double left,
      required double top,
      required double width,
      required double height,
      required VoidCallback? onTap,
    }) {
      return Positioned(
        left: left,
        top: top,
        width: width,
        height: height,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: const SizedBox.expand(),
        ),
      );
    }

    return [
      target(
        left: center - armHalf,
        top: 0,
        width: arm,
        height: center - armHalf,
        onTap: onUp,
      ),
      target(
        left: center - armHalf,
        top: center + armHalf,
        width: arm,
        height: center - armHalf,
        onTap: onDown,
      ),
      target(
        left: 0,
        top: center - armHalf,
        width: center - armHalf,
        height: arm,
        onTap: onLeft,
      ),
      target(
        left: center + armHalf,
        top: center - armHalf,
        width: center - armHalf,
        height: arm,
        onTap: onRight,
      ),
    ];
  }
}

class _DpadShape extends StatelessWidget {
  const _DpadShape({
    required this.size,
    required this.arm,
    required this.radius,
    required this.fillColor,
    required this.showBorder,
  });

  final double size;
  final double arm;
  final double radius;
  final Color fillColor;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _DpadShapePainter(
        arm: arm,
        radius: radius,
        fillColor: fillColor,
        showBorder: showBorder,
      ),
    );
  }
}

class _DpadShapePainter extends CustomPainter {
  const _DpadShapePainter({
    required this.arm,
    required this.radius,
    required this.fillColor,
    required this.showBorder,
  });

  final double arm;
  final double radius;
  final Color fillColor;
  final bool showBorder;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final path = Path();

    final vertical = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: arm,
        height: size.width,
      ),
      Radius.circular(radius),
    );

    final horizontal = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: size.width,
        height: arm,
      ),
      Radius.circular(radius),
    );

    path.addRRect(vertical);
    path.addRRect(horizontal);

    canvas.drawPath(path, Paint()..color = fillColor);

    if (showBorder) {
      canvas.drawPath(
        path,
        Paint()
          ..color = PokedexControlPanelColors.outline
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DpadShapePainter oldDelegate) => false;
}
