import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pokedex/data/cache/pokemon_details_cache.dart';
import 'package:pokedex/data/models/featured_pokemon_details.dart';
import 'package:pokedex/data/models/pokemon.dart';
import 'package:pokedex/data/models/pokemon_stats.dart';
import 'package:pokedex/data/repositories/pokemon_repository.dart';
import 'package:pokedex/data/services/pokeapi_service.dart';

void main() {
  test('fetchFeaturedPokemonDetails usa cache após primeira busca', () async {
    var pokemonRequests = 0;

    final client = MockClient((request) async {
      final path = request.url.path;

      if (path.endsWith('/pokemon/bulbasaur')) {
        pokemonRequests++;
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
                'flavor_text': 'Cached description.',
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

    final cache = PokemonDetailsCache();
    final repository = PokemonRepository(
      service: PokeApiService(client: client),
      cache: cache,
    );

    final first = await repository.fetchFeaturedPokemonDetails('bulbasaur');
    final second = await repository.fetchFeaturedPokemonDetails('bulbasaur');

    expect(first.description, 'Cached description.');
    expect(second.description, 'Cached description.');
    expect(pokemonRequests, 1);
    expect(cache.length, 1);
  });

  test('retainOnly remove entradas fora da janela de preload', () {
    final cache = PokemonDetailsCache();

    cache.put(
      'bulbasaur',
      FeaturedPokemonDetails(
        pokemon: Pokemon(
          id: 1,
          name: 'bulbasaur',
          imageUrl: null,
          types: const ['grass'],
          height: 7,
          weight: 69,
          stats: const PokemonStats(
            hp: 45,
            attack: 49,
            defense: 49,
            specialAttack: 65,
            specialDefense: 65,
            speed: 45,
          ),
          abilities: const [],
        ),
        description: 'A',
        genus: 'Seed',
      ),
    );

    cache.put(
      'ivysaur',
      FeaturedPokemonDetails(
        pokemon: Pokemon(
          id: 2,
          name: 'ivysaur',
          imageUrl: null,
          types: const ['grass'],
          height: 10,
          weight: 130,
          stats: const PokemonStats(
            hp: 60,
            attack: 62,
            defense: 63,
            specialAttack: 80,
            specialDefense: 80,
            speed: 60,
          ),
          abilities: const [],
        ),
        description: 'B',
        genus: 'Seed',
      ),
    );

    cache.retainOnly({'bulbasaur'});

    expect(cache.get('bulbasaur'), isNotNull);
    expect(cache.get('ivysaur'), isNull);
    expect(cache.length, 1);
  });
}
