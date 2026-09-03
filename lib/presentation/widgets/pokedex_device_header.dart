import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex/core/constants/app_assets.dart';
import 'package:pokedex/presentation/widgets/pokemon_stats_radar_chart.dart';
import 'package:pokedex/presentation/widgets/pokemon_animated_sprite.dart';
import 'package:pokedex/presentation/widgets/pokedex_control_panel.dart';
import 'package:pokedex/presentation/widgets/pokedex_top_cap.dart';
import 'package:pokedex/data/models/pokemon_stats.dart';
import 'package:pokedex/providers/pokemon_providers.dart';

abstract final class PokedexDeviceColors {
  static const backgroundRed = Color(0xFFE21C26);
  static const frameGray = Color(0xFFD9D9D9);
  static const frameShadow = Color(0xFFB8B8B8);
  static const outline = Color(0xFF1F1F1F);
  static const screen = Color(0xFF2B2B2B);
  static const screenBorder = Color(0xFF000000);
  static const accentRed = Color(0xFFE21C26);
}

abstract final class PokedexDeviceLayout {
  static const topPadding = 55.0;
  static const grayCardTopPadding = 15.0;
  static const horizontalPadding = 18.0;
  static const controlPanelBottomPadding = 50.0;
  static const screenBottomGap = 10.0;
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
    final screenHeight = MediaQuery.sizeOf(context).height;

    return SizedBox(
      height: screenHeight,
      child: ColoredBox(
        color: PokedexDeviceColors.backgroundRed,
        child: Column(
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
            const Padding(
              padding: EdgeInsets.only(
                bottom: PokedexDeviceLayout.controlPanelBottomPadding,
              ),
              child: PokedexControlPanel(),
            ),
          ],
        ),
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
                        child: _PokedexScreen(
                          backgroundImage: AppAssets.campo,
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

class _PokedexScreen extends ConsumerStatefulWidget {
  const _PokedexScreen({
    required this.backgroundImage,
  });

  final String backgroundImage;

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
      if (previous != next) {
        final controller = ref.read(descriptionScrollControllerProvider);
        if (controller.hasClients) {
          controller.jumpTo(0);
        }
      }
    });

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: PokedexDeviceColors.screenBorder,
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: ColoredBox(
        color: PokedexDeviceColors.screen,
        child: _buildContent(listState),
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

    final featuredAsync = ref.watch(featuredPokemonProvider);

    return featuredAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      ),
      error: (error, stackTrace) => Center(
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
      ),
      data: (featured) => Column(
        children: [
          Expanded(
            flex: 50,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  widget.backgroundImage,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Center(
                      child: PokemonAnimatedSprite(
                        pokemonName: featured.pokemon.name,
                        maxWidth: constraints.maxWidth * 0.50,
                        maxHeight: constraints.maxHeight * 0.50,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            flex: 50,
            child: _PokemonDescriptionSection(
              key: ValueKey(featured.pokemon.id),
              description: featured.description,
              stats: featured.pokemon.stats,
              pokemonId: featured.pokemon.id,
            ),
          ),
        ],
      ),
    );
  }
}

class _PokemonDescriptionSection extends ConsumerWidget {
  const _PokemonDescriptionSection({
    super.key,
    required this.description,
    required this.stats,
    required this.pokemonId,
  });

  final String description;
  final PokemonStats stats;
  final int pokemonId;

  static const _labelStyle = TextStyle(
    color: Colors.white,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
  );

  static const _bodyStyle = TextStyle(
    color: Color(0xFFD6D6D6),
    fontSize: 11,
    height: 1.35,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = ref.watch(descriptionScrollControllerProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Descrição:', style: _labelStyle),
          const SizedBox(height: 6),
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(description, style: _bodyStyle),
                  const SizedBox(height: 14),
                  const Text('Stats:', style: _labelStyle),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: PokemonStatsRadarChart(
                      stats: stats,
                      pokemonId: pokemonId,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
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
