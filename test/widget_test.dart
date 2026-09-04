import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pokedex/main.dart';
import 'package:pokedex/presentation/widgets/pokedex_device_header.dart';
import 'package:pokedex/providers/pokemon_providers.dart';

http.Client _mockPokeApiClient() {
  return MockClient((request) async {
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
            {'type': {'name': 'poison'}},
          ],
          'abilities': [
            {
              'ability': {'name': 'overgrow'},
              'is_hidden': false,
              'slot': 1,
            },
            {
              'ability': {'name': 'chlorophyll'},
              'is_hidden': true,
              'slot': 3,
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
}

void main() {
  testWidgets('Exibe o header da Pokédex', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          httpClientProvider.overrideWithValue(_mockPokeApiClient()),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SizedBox.expand(
              child: PokedexDeviceHeader(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(PokedexDeviceHeader), findsOneWidget);
  });

  testWidgets('Exibe a listagem após a splash', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          httpClientProvider.overrideWithValue(_mockPokeApiClient()),
        ],
        child: const PokedexApp(),
      ),
    );

    await tester.pump();
    for (var frame = 0; frame < 30; frame++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.byType(PokedexDeviceHeader).evaluate().isNotEmpty) {
        break;
      }
    }

    expect(find.byType(PokedexDeviceHeader), findsOneWidget);
  });
}
