import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pokedex/data/cache/pokemon_details_cache.dart';
import 'package:pokedex/data/repositories/pokemon_repository.dart';
import 'package:pokedex/data/services/description_translator.dart';
import 'package:pokedex/data/services/pokeapi_service.dart';

class _FakeDescriptionTranslator implements DescriptionTranslator {
  @override
  Future<String> translateEnglishToPortuguese(String text) async {
    return 'Traduzido: $text';
  }
}

void main() {
  test('fetchFeaturedPokemonDetails traduz descrição em inglês', () async {
    final client = MockClient((request) async {
      final path = request.url.path;

      if (path.endsWith('/pokemon/bulbasaur')) {
        return http.Response(
          jsonEncode({
            'id': 1,
            'name': 'bulbasaur',
            'height': 7,
            'weight': 69,
            'sprites': {'front_default': 'https://example.com/sprite.png'},
            'types': [
              {'type': {'name': 'grass'}},
            ],
            'abilities': [],
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
                'flavor_text': 'English description.',
                'language': {'name': 'en'},
              },
            ],
            'genera': [],
          }),
          200,
        );
      }

      return http.Response('Not Found', 404);
    });

    final repository = PokemonRepository(
      service: PokeApiService(client: client),
      cache: PokemonDetailsCache(),
      descriptionTranslator: _FakeDescriptionTranslator(),
    );

    final details = await repository.fetchFeaturedPokemonDetails('bulbasaur');

    expect(details.description, 'Traduzido: English description.');
  });
}
