import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex/providers/pokemon_providers.dart';

abstract final class PokedexControlPanelColors {
  static const outline = Color(0xFF1F1F1F);
  static const actionBlue = Color(0xFF00D4FF);
  static const actionBlueHighlight = Color(0xFF66E8FF);
  static const actionBlueMid = Color(0xFF00C8F0);
  static const actionBlueShadow = Color(0xFF008FB0);
  static const actionBlueDeepShadow = Color(0xFF006A85);
  static const pillGreen = Color(0xFF3DDC4A);
  static const pillGreenHighlight = Color(0xFF72F07C);
  static const pillGreenMid = Color(0xFF3DDC4A);
  static const pillGreenShadow = Color(0xFF2AB535);
  static const pillGreenDeepShadow = Color(0xFF1E8F28);
  static const pillCreamHighlight = Color(0xFFFFB59A);
  static const pillCreamMid = Color(0xFFFF8A65);
  static const pillCreamShadow = Color(0xFFE86F4A);
  static const pillCreamDeepShadow = Color(0xFFC45638);
  static const displayYellowBezel = Color(0xFFE8C200);
  static const displayYellowBezelHighlight = Color(0xFFFFF0A0);
  static const displayYellowBezelShadow = Color(0xFFB89600);
  static const displayScreen = Color(0xFFD6BC00);
  static const displayScreenDeep = Color(0xFFB89E00);
  static const dpadNavy = Color(0xFF1B2A4E);
  static const dpadHighlight = Color(0xFF3D5685);
  static const dpadMid = Color(0xFF243A66);
  static const dpadShadow = Color(0xFF0F1A33);
  static const dpadDeepShadow = Color(0xFF080E1A);
  static const dpadArrow = Color(0xFF8FA6D4);
  static const dpadArrowShadow = Color(0xFF2A3D66);
  static const dpadHubBase = Color(0xFF2A3D66);
  static const dpadHubHighlight = Color(0xFF4A6AA0);
  static const dpadHubShadow = Color(0xFF152238);
}

abstract final class PokedexControlPanelLayout {
  static const horizontalPadding = 18.0;
  static const verticalPadding = 16.0;
}

class PokedexControlPanel extends ConsumerWidget {
  const PokedexControlPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(pokedexNavigationProvider).index;
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
                      const _StatusPill(
                        highlight: PokedexControlPanelColors.pillGreenHighlight,
                        mid: PokedexControlPanelColors.pillGreenMid,
                        shadow: PokedexControlPanelColors.pillGreenShadow,
                        deepShadow: PokedexControlPanelColors.pillGreenDeepShadow,
                      ),
                      const SizedBox(width: 8),
                      const _StatusPill(
                        highlight: PokedexControlPanelColors.pillCreamHighlight,
                        mid: PokedexControlPanelColors.pillCreamMid,
                        shadow: PokedexControlPanelColors.pillCreamShadow,
                        deepShadow: PokedexControlPanelColors.pillCreamDeepShadow,
                      ),
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

class _ActionBlueButton extends StatefulWidget {
  const _ActionBlueButton({required this.size});

  final double size;

  @override
  State<_ActionBlueButton> createState() => _ActionBlueButtonState();
}

class _ActionBlueButtonState extends State<_ActionBlueButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
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
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _pressed
                  ? const [
                      PokedexControlPanelColors.actionBlueMid,
                      PokedexControlPanelColors.actionBlue,
                      PokedexControlPanelColors.actionBlueDeepShadow,
                    ]
                  : const [
                      PokedexControlPanelColors.actionBlueHighlight,
                      PokedexControlPanelColors.actionBlueMid,
                      PokedexControlPanelColors.actionBlueShadow,
                    ],
            ),
            border: Border.all(
              color: PokedexControlPanelColors.outline,
              width: 2.5,
            ),
            boxShadow: _pressed
                ? const []
                : const [
                    BoxShadow(
                      color: Color(0x66000000),
                      offset: Offset(2.5, 3.5),
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
                            Colors.white.withValues(alpha: 0.22),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatefulWidget {
  const _StatusPill({
    required this.highlight,
    required this.mid,
    required this.shadow,
    required this.deepShadow,
  });

  final Color highlight;
  final Color mid;
  final Color shadow;
  final Color deepShadow;

  @override
  State<_StatusPill> createState() => _StatusPillState();
}

class _StatusPillState extends State<_StatusPill> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final pressOffset = _pressed ? const Offset(1, 1) : Offset.zero;

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
          width: 59,
          height: 16,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _pressed
                  ? [widget.mid, widget.shadow, widget.deepShadow]
                  : [widget.highlight, widget.mid, widget.shadow],
            ),
            border: Border.all(
              color: PokedexControlPanelColors.outline,
              width: 2,
            ),
            boxShadow: _pressed
                ? const []
                : const [
                    BoxShadow(
                      color: Color(0x66000000),
                      offset: Offset(2, 2.5),
                      blurRadius: 1.5,
                    ),
                    BoxShadow(
                      color: Color(0x44000000),
                      offset: Offset(1, 1),
                      blurRadius: 0,
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
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
                            Colors.white.withValues(alpha: 0.2),
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
                            Colors.black.withValues(alpha: 0.16),
                            Colors.transparent,
                          ],
                        ),
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

class _YellowDisplayCard extends StatelessWidget {
  const _YellowDisplayCard({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PokedexControlPanelColors.displayYellowBezelHighlight,
            PokedexControlPanelColors.displayYellowBezel,
            PokedexControlPanelColors.displayYellowBezelShadow,
          ],
        ),
        border: Border.all(
          color: PokedexControlPanelColors.outline,
          width: 2.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            offset: Offset(2, 2.5),
            blurRadius: 1.5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      PokedexControlPanelColors.displayScreenDeep,
                      PokedexControlPanelColors.displayScreen,
                      PokedexControlPanelColors.displayYellowBezelShadow,
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.center,
                    colors: [
                      Colors.black.withValues(alpha: 0.34),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomRight,
                    end: Alignment.center,
                    colors: [
                      Colors.white.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              top: 0,
              bottom: 0,
              child: Align(
                alignment: Alignment.centerLeft,
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
                      shadows: [
                        Shadow(
                          color: Color(0x33FFFFFF),
                          offset: Offset(0, -0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
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
    final center = size / 2;
    final armHalf = arm / 2;
    final armLength = center - armHalf;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
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
          Positioned(
            left: center - armHalf,
            top: 0,
            width: arm,
            height: armLength,
            child: _DpadArmButton(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(radius),
                topRight: Radius.circular(radius),
              ),
              onTap: onUp,
            ),
          ),
          Positioned(
            left: center - armHalf,
            top: center + armHalf,
            width: arm,
            height: armLength,
            child: _DpadArmButton(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(radius),
                bottomRight: Radius.circular(radius),
              ),
              onTap: onDown,
            ),
          ),
          Positioned(
            left: 0,
            top: center - armHalf,
            width: armLength,
            height: arm,
            child: _DpadArmButton(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(radius),
                bottomLeft: Radius.circular(radius),
              ),
              onTap: onLeft,
            ),
          ),
          Positioned(
            left: center + armHalf,
            top: center - armHalf,
            width: armLength,
            height: arm,
            child: _DpadArmButton(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(radius),
                bottomRight: Radius.circular(radius),
              ),
              onTap: onRight,
            ),
          ),
          ..._buildArrows(size, arm),
          _DpadCenterHub(size: arm * 0.9),
        ],
      ),
    );
  }

  List<Widget> _buildArrows(double size, double arm) {
    final arrowSize = size * 0.22;
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
        child: IgnorePointer(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.translate(
                offset: const Offset(1, 1.5),
                child: Icon(
                  icon,
                  size: arrowSize,
                  color: PokedexControlPanelColors.dpadArrowShadow,
                ),
              ),
              Icon(
                icon,
                size: arrowSize,
                color: PokedexControlPanelColors.dpadArrow,
              ),
            ],
          ),
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
}

class _DpadArmButton extends StatefulWidget {
  const _DpadArmButton({
    required this.borderRadius,
    this.onTap,
  });

  final BorderRadius borderRadius;
  final VoidCallback? onTap;

  @override
  State<_DpadArmButton> createState() => _DpadArmButtonState();
}

class _DpadArmButtonState extends State<_DpadArmButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final pressOffset = _pressed ? const Offset(1, 1.5) : Offset.zero;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      behavior: HitTestBehavior.opaque,
      child: Transform.translate(
        offset: pressOffset,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 70),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _pressed
                  ? const [
                      PokedexControlPanelColors.dpadMid,
                      PokedexControlPanelColors.dpadNavy,
                      PokedexControlPanelColors.dpadDeepShadow,
                    ]
                  : const [
                      PokedexControlPanelColors.dpadHighlight,
                      PokedexControlPanelColors.dpadMid,
                      PokedexControlPanelColors.dpadShadow,
                    ],
            ),
            boxShadow: _pressed
                ? const []
                : const [
                    BoxShadow(
                      color: Color(0x66000000),
                      offset: Offset(2.5, 3.5),
                      blurRadius: 2,
                    ),
                    BoxShadow(
                      color: Color(0x44000000),
                      offset: Offset(1, 1.5),
                      blurRadius: 0,
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: widget.borderRadius,
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
                            Colors.white.withValues(alpha: 0.14),
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
                            Colors.black.withValues(alpha: 0.22),
                            Colors.transparent,
                          ],
                        ),
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

class _DpadCenterHub extends StatelessWidget {
  const _DpadCenterHub({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              PokedexControlPanelColors.dpadHubHighlight,
              PokedexControlPanelColors.dpadHubBase,
              PokedexControlPanelColors.dpadHubShadow,
            ],
          ),
          border: Border.all(
            color: PokedexControlPanelColors.outline,
            width: 2,
          ),
          boxShadow: const [
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
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.center,
                      colors: [
                        Colors.white.withValues(alpha: 0.18),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomRight,
                      end: Alignment.center,
                      colors: [
                        Colors.black.withValues(alpha: 0.28),
                        Colors.transparent,
                      ],
                    ),
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
