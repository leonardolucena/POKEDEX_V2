import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pokedex/core/constants/pokemon_sprite_urls.dart';

class PokemonAnimatedSprite extends StatelessWidget {
  const PokemonAnimatedSprite({
    super.key,
    required this.pokemonName,
    this.maxWidth,
    this.maxHeight,
  });

  final String pokemonName;
  final double? maxWidth;
  final double? maxHeight;

  /// Sprites animados de Gen 5 no PokemonDB são bem pequenos (~96px).
  static const _nativeMaxDimension = 96.0;
  static const _maxUpscaleFactor = 2.5;

  @override
  Widget build(BuildContext context) {
    final absoluteMax = _nativeMaxDimension * _maxUpscaleFactor;
    final width = math.min(maxWidth ?? absoluteMax, absoluteMax);
    final height = math.min(maxHeight ?? absoluteMax, absoluteMax);

    return Image(
      image: NetworkImage(PokemonSpriteUrls.blackWhiteAnimated(pokemonName)),
      width: width,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      isAntiAlias: true,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
    );
  }
}
