import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex/presentation/widgets/pokemon_background_transition.dart';
import 'package:pokedex/presentation/widgets/pokemon_description_transition.dart';
import 'package:pokedex/presentation/widgets/pokemon_sprite_transition.dart';
import 'package:pokedex/presentation/widgets/pokedex_control_panel.dart';
import 'package:pokedex/presentation/widgets/pokedex_top_cap.dart';
import 'package:pokedex/providers/pokemon_providers.dart';

abstract final class PokedexDeviceColors {
  static const backgroundRed = Color(0xFFE21C26);
  static const frameGray = Color(0xFFD9D9D9);
  static const frameGrayHighlight = Color(0xFFF2F2F2);
  static const frameGrayMid = Color(0xFFD9D9D9);
  static const frameGrayShadow = Color(0xFFB0B0B0);
  static const frameDropShadow = Color(0x59000000);
  static const frameDropShadowTight = Color(0x3D000000);
  static const outline = Color(0xFF1F1F1F);
  static const screen = Color(0xFF2B2B2B);
  static const screenDeep = Color(0xFF181818);
  static const screenSurface = Color(0xFF232323);
  static const screenBezelHighlight = Color(0xFF4A4A4A);
  static const screenBezel = Color(0xFF333333);
  static const screenBezelShadow = Color(0xFF1A1A1A);
  static const screenBorder = Color(0xFF000000);
  static const accentRed = Color(0xFFE21C26);
  static const accentRedHighlight = Color(0xFFFF5A63);
  static const accentRedMid = Color(0xFFE21C26);
  static const accentRedShadow = Color(0xFFB81820);
  static const accentRedDeepShadow = Color(0xFF8A1218);
  static const speakerGroove = Color(0xFF141414);
  static const speakerGrooveDeep = Color(0xFF0A0A0A);
  static const speakerGrooveLip = Color(0xFF4A4A4A);
  static const infoLabelBlue = Color(0xFF00D4FF);
  static const infoValueYellow = Color(0xFFF0C84B);
}

abstract final class PokedexDeviceLayout {
  static const topPadding = 55.0;
  static const grayCardTopPadding = 15.0;
  static const horizontalPadding = 18.0;
  static const controlPanelBottomPadding = 50.0;
  static const screenBottomGap = 10.0;
  static const frameInset = 16.0;
  static const bottomButtonSize = 38.0;
  static const speakerWidthExtra = 10.0;
  static const speakerLineHeight = 4.0;
  static const speakerLineSpacing = 7.0;
  static const frameBorderWidth = 2.0;
  static const frameShadowOffset = Offset(6, 8);
  static const frameShadowBlur = 14.0;
  static const frameShadowTightOffset = Offset(2.5, 3.5);
  static const frameShadowTightBlur = 5.0;
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
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final topCapHeight = screenWidth * 0.28;

    return SizedBox(
      height: screenHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: PokedexDeviceColors.backgroundRed),
          CustomPaint(
            painter: PokedexShellRecessPainter(
              topCapTop: PokedexDeviceLayout.topPadding,
              topCapHeight: topCapHeight,
            ),
          ),
          Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: PokedexDeviceLayout.topPadding),
                child: PokedexTopCap(),
              ),
              const SizedBox(height: PokedexDeviceLayout.grayCardTopPadding),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PokedexDeviceLayout.horizontalPadding,
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Positioned.fill(
                        child: CustomPaint(
                          painter: _PokedexFrameShadowPainter(),
                        ),
                      ),
                      const Positioned.fill(
                        child: _PokedexFrame(),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(
                  bottom: PokedexDeviceLayout.controlPanelBottomPadding,
                ),
                child: PokedexControlPanel(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PokedexFrame extends StatelessWidget {
  const _PokedexFrame();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipPath(
          clipper: const PokedexFrameClipper(),
          child: CustomPaint(
            painter: const _PokedexFramePainter(),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final inset = PokedexDeviceLayout.frameInset;
                final screenTop = inset + 14 + 12;
                final bottomReserved = inset +
                    PokedexDeviceLayout.bottomButtonSize +
                    PokedexDeviceLayout.screenBottomGap;
                final screenHeight =
                    constraints.maxHeight - screenTop - bottomReserved;

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
                      height: screenHeight.clamp(0, double.infinity),
                      child: const _PokedexScreen(),
                    ),
                    Positioned(
                      left: PokedexDeviceLayout.frameInset + 20,
                      bottom: PokedexDeviceLayout.frameInset,
                      child: const _IndicatorLight(
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
            ),
          ),
        ),
        const CustomPaint(
          painter: _PokedexFrameBorderPainter(),
        ),
      ],
    );
  }
}

class _PokedexScreen extends ConsumerStatefulWidget {
  const _PokedexScreen();

  @override
  ConsumerState<_PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends ConsumerState<_PokedexScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final listState = ref.read(pokemonListNotifierProvider);
      if (listState.items.isEmpty && !listState.isLoading) {
        ref.read(pokemonListNotifierProvider.notifier).refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(pokemonListNotifierProvider);

    ref.listen(pokedexNavigationProvider, (previous, next) {
      if (previous?.index != next.index) {
        final controller = ref.read(descriptionScrollControllerProvider);
        if (controller.hasClients) {
          controller.jumpTo(0);
        }
      }
    });

    ref.listen(featuredPokemonProvider, (previous, next) {
      if (next is AsyncData<FeaturedPokemonDetails>) {
        ref.read(pokedexNavigationProvider.notifier).preloadNearbyDetails();
      }
    });

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PokedexDeviceColors.screenBezelHighlight,
            PokedexDeviceColors.screenBezel,
            PokedexDeviceColors.screenBezelShadow,
          ],
        ),
        border: Border.all(
          color: PokedexDeviceColors.screenBorder,
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            offset: Offset(2, 2.5),
            blurRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      PokedexDeviceColors.screenDeep,
                      PokedexDeviceColors.screenSurface,
                      PokedexDeviceColors.screen,
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
                      Colors.black.withValues(alpha: 0.45),
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
                      Colors.white.withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            _buildContent(listState),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(PokemonListState listState) {
    if (listState.items.isEmpty) {
      if (listState.isLoading) {
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        );
      }

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Falha ao carregar os dados.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => reloadPokedexData(ref),
                child: const Text(
                  'Tentar novamente',
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          flex: 50,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const PokemonBackgroundTransition(),
              LayoutBuilder(
                builder: (context, constraints) {
                  return PokemonSpriteTransition(
                    stageWidth: constraints.maxWidth,
                    stageHeight: constraints.maxHeight,
                    maxWidth: constraints.maxWidth * 0.50,
                    maxHeight: constraints.maxHeight * 0.50,
                  );
                },
              ),
              _buildDexNumberOverlay(listState),
            ],
          ),
        ),
        const Expanded(
          flex: 50,
          child: PokemonDescriptionTransition(),
        ),
      ],
    );
  }

  Widget _buildDexNumberOverlay(PokemonListState listState) {
    final featured = ref.watch(featuredPokemonProvider);
    final dexNumber = featured.maybeWhen(
      data: (details) => '#${details.pokemon.id.toString().padLeft(3, '0')}',
      orElse: () {
        final index = ref.watch(pokedexNavigationProvider).index;
        final safeIndex = index.clamp(0, listState.items.length - 1);
        final id = listState.items[safeIndex].id;
        if (id == null) return null;
        return '#${id.toString().padLeft(3, '0')}';
      },
    );

    if (dexNumber == null) return const SizedBox.shrink();

    return Positioned(
      top: 5,
      right: 5,
      child: _OutlinedDexNumber(text: dexNumber),
    );
  }
}

class _OutlinedDexNumber extends StatelessWidget {
  const _OutlinedDexNumber({required this.text});

  final String text;

  static const _fontSize = 12.0;

  @override
  Widget build(BuildContext context) {
    const baseStyle = TextStyle(
      fontSize: _fontSize,
      height: 1.5,
      fontWeight: FontWeight.w600,
    );

    return Stack(
      children: [
        Text(
          text,
          style: baseStyle.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2
              ..color = Colors.black,
          ),
        ),
        Text(
          text,
          style: baseStyle.copyWith(color: Colors.white),
        ),
      ],
    );
  }
}

class _PokedexFramePainter extends CustomPainter {
  const _PokedexFramePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final clipper = PokedexFrameClipper();
    final path = clipper.getClip(size);
    final bounds = path.getBounds();

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          PokedexDeviceColors.frameGrayHighlight,
          PokedexDeviceColors.frameGrayMid,
          PokedexDeviceColors.frameGrayShadow,
        ],
      ).createShader(bounds);
    canvas.drawPath(path, fillPaint);

    canvas.save();
    canvas.clipPath(path);

    final highlightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.center,
        colors: [
          Colors.white.withValues(alpha: 0.28),
          Colors.white.withValues(alpha: 0.04),
          Colors.transparent,
        ],
        stops: const [0, 0.35, 1],
      ).createShader(bounds);
    canvas.drawRect(bounds, highlightPaint);

    final shadePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomRight,
        end: Alignment.center,
        colors: [
          Colors.black.withValues(alpha: 0.18),
          Colors.black.withValues(alpha: 0.05),
          Colors.transparent,
        ],
        stops: const [0, 0.4, 1],
      ).createShader(bounds);
    canvas.drawRect(bounds, shadePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PokedexFramePainter oldDelegate) => false;
}

class _PokedexFrameShadowPainter extends CustomPainter {
  const _PokedexFrameShadowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = const PokedexFrameClipper().getClip(size);

    _drawShadowLayer(
      canvas,
      path,
      offset: PokedexDeviceLayout.frameShadowOffset,
      blur: PokedexDeviceLayout.frameShadowBlur,
      color: PokedexDeviceColors.frameDropShadow,
    );
    _drawShadowLayer(
      canvas,
      path,
      offset: PokedexDeviceLayout.frameShadowTightOffset,
      blur: PokedexDeviceLayout.frameShadowTightBlur,
      color: PokedexDeviceColors.frameDropShadowTight,
    );
  }

  void _drawShadowLayer(
    Canvas canvas,
    Path path,
    {
    required Offset offset,
    required double blur,
    required Color color,
  }) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PokedexFrameShadowPainter oldDelegate) => false;
}

class _PokedexFrameBorderPainter extends CustomPainter {
  const _PokedexFrameBorderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = const PokedexFrameClipper().getClip(size);

    canvas.drawPath(
      path,
      Paint()
        ..color = PokedexDeviceColors.outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = PokedexDeviceLayout.frameBorderWidth,
    );
  }

  @override
  bool shouldRepaint(covariant _PokedexFrameBorderPainter oldDelegate) {
    return false;
  }
}

class _IndicatorLight extends StatefulWidget {
  const _IndicatorLight({required this.size});

  final double size;

  @override
  State<_IndicatorLight> createState() => _IndicatorLightState();
}

class _IndicatorLightState extends State<_IndicatorLight> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final borderWidth = widget.size >= 24 ? 2.0 : 1.5;
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
                  ? const [
                      PokedexDeviceColors.accentRedMid,
                      PokedexDeviceColors.accentRed,
                      PokedexDeviceColors.accentRedDeepShadow,
                    ]
                  : const [
                      PokedexDeviceColors.accentRedHighlight,
                      PokedexDeviceColors.accentRedMid,
                      PokedexDeviceColors.accentRedShadow,
                    ],
            ),
            border: Border.all(
              color: PokedexDeviceColors.outline,
              width: borderWidth,
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
                            Colors.white.withValues(alpha: 0.24),
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
              ],
            ),
          ),
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
            child: const _SpeakerGrilleLine(),
          );
        }),
      ),
    );
  }
}

class _SpeakerGrilleLine extends StatelessWidget {
  const _SpeakerGrilleLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: PokedexDeviceLayout.speakerLineHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PokedexDeviceColors.speakerGrooveLip,
            PokedexDeviceColors.speakerGrooveDeep,
            PokedexDeviceColors.speakerGroove,
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            offset: Offset(0, 1.5),
            blurRadius: 0.5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.55),
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.06),
                    ],
                    stops: const [0, 0.55, 1],
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
