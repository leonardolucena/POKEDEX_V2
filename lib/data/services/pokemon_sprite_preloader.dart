import 'dart:async';

import 'package:flutter/painting.dart';
import 'package:pokedex/core/constants/pokemon_sprite_urls.dart';

Future<void> preloadAnimatedSprite(String pokemonName) async {
  final provider = NetworkImage(
    PokemonSpriteUrls.blackWhiteAnimated(pokemonName),
  );
  final stream = provider.resolve(const ImageConfiguration());
  final completer = Completer<void>();

  late final ImageStreamListener listener;
  listener = ImageStreamListener(
    (_, _) {
      stream.removeListener(listener);
      if (!completer.isCompleted) {
        completer.complete();
      }
    },
    onError: (_, _) {
      stream.removeListener(listener);
      if (!completer.isCompleted) {
        completer.complete();
      }
    },
  );

  stream.addListener(listener);

  try {
    await completer.future.timeout(const Duration(seconds: 8));
  } on TimeoutException {
    stream.removeListener(listener);
  }
}
