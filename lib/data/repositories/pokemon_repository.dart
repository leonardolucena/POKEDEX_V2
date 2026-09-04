import 'package:pokedex/data/cache/pokemon_details_cache.dart';
import 'package:pokedex/data/models/featured_pokemon_details.dart';
import 'package:pokedex/data/models/pokemon.dart';
import 'package:pokedex/data/models/pokemon_list_response.dart';
import 'package:pokedex/data/models/pokemon_species.dart';
import 'package:pokedex/data/services/pokeapi_service.dart';

class PokemonRepository {
  PokemonRepository({
    required PokeApiService service,
    required PokemonDetailsCache cache,
  })  : _service = service,
        _cache = cache;

  final PokeApiService _service;
  final PokemonDetailsCache _cache;

  Future<PokemonListResponse> fetchPokemonList({
    int limit = 20,
    int offset = 0,
  }) {
    return _service.fetchPokemonList(limit: limit, offset: offset);
  }

  Future<Pokemon> fetchPokemon(String idOrName) {
    return _service.fetchPokemon(idOrName);
  }

  Future<PokemonSpecies> fetchPokemonSpecies(String idOrName) {
    return _service.fetchPokemonSpecies(idOrName);
  }

  FeaturedPokemonDetails? getCachedFeaturedDetails(String pokemonName) {
    return _cache.get(pokemonName);
  }

  Future<FeaturedPokemonDetails> fetchFeaturedPokemonDetails(
    String pokemonName,
  ) async {
    final cached = _cache.get(pokemonName);
    if (cached != null) return cached;

    final results = await Future.wait([
      fetchPokemon(pokemonName),
      fetchPokemonSpecies(pokemonName),
    ]);

    final pokemon = results[0] as Pokemon;
    final species = results[1] as PokemonSpecies;

    final details = FeaturedPokemonDetails(
      pokemon: pokemon,
      description: species.description,
      genus: species.genus,
    );

    _cache.put(pokemonName, details);
    return details;
  }

  Future<void> preloadFeaturedPokemonDetails(List<String> pokemonNames) async {
    for (final name in pokemonNames) {
      if (_cache.get(name) != null) continue;
      try {
        await fetchFeaturedPokemonDetails(name);
      } catch (_) {
        // Preload falhou para um Pokémon; não bloqueia os demais.
      }
    }
  }

  void retainCachedFeaturedDetails(Set<String> pokemonNames) {
    _cache.retainOnly(pokemonNames);
  }
}
