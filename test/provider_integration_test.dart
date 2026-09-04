import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pokedex/providers/pokemon_providers.dart';
import 'package:pokedex/data/services/description_translator.dart';

void main() {
  test('featuredPokemonProvider carrega dados sem modificar providers durante build',
      () async {
    final client = MockClient((request) async {
      final path = request.url.path;

      if (path.endsWith('/pokemon') &&
          request.url.queryParameters.containsKey('limit')) {
        return http.Response(
          jsonEncode({
            'count': 1,
            'next': null,
            'previous': null,
            'results': [
              {
                'name': 'bulbasaur',
                'url': 'https://pokeapi.co/api/v2/pokemon/1/',
              },
            ],
          }),
          200,
        );
      }

      if (path.endsWith('/pokemon/bulbasaur')) {
        return http.Response(
          jsonEncode({
            'id': 1,
            'name': 'bulbasaur',
            'height': 7,
            'weight': 69,
            'sprites': {
              'front_default': 'https://example.com/sprite.png',
            },
            'types': [
              {'type': {'name': 'grass'}},
            ],
            'abilities': [
              {
                'ability': {'name': 'overgrow'},
                'is_hidden': false,
                'slot': 1,
              },
            ],
            'stats': [
              {'base_stat': 45, 'stat': {'name': 'hp'}},
              {'base_stat': 49, 'stat': {'name': 'attack'}},
              {'base_stat': 49, 'stat': {'name': 'defense'}},
              {'base_stat': 65, 'stat': {'name': 'special-attack'}},
              {'base_stat': 65, 'stat': {'name': 'special-defense'}},
              {'base_stat': 45, 'stat': {'name': 'speed'}},
            ],
          }),
          200,
        );
      }

      if (path.endsWith('/pokemon-species/bulbasaur')) {
        return http.Response(
          jsonEncode({
            'id': 1,
            'name': 'bulbasaur',
            'flavor_text_entries': [
              {
                'flavor_text': 'Test description.',
                'language': {'name': 'en'},
              },
            ],
            'genera': [
              {
                'genus': 'Seed Pokémon',
                'language': {'name': 'en'},
              },
            ],
          }),
          200,
        );
      }

      return http.Response('Not Found', 404);
    });

    final container = ProviderContainer(
      overrides: [
        httpClientProvider.overrideWithValue(client),
        descriptionTranslatorProvider.overrideWithValue(
          PassthroughDescriptionTranslator(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(pokemonListNotifierProvider.notifier).refresh();

    final listState = container.read(pokemonListNotifierProvider);
    expect(listState.error, isNull, reason: '${listState.error}');
    expect(listState.items, isNotEmpty);

    final featured = await container.read(featuredPokemonProvider.future);
    expect(featured.pokemon.name, 'bulbasaur');
    expect(featured.description, 'Test description.');
    expect(featured.genus, 'Seed Pokémon');
    expect(featured.pokemon.abilities, hasLength(1));
    expect(featured.pokemon.stats.total, 318);
  });
}
