import 'package:pokedex/data/models/featured_pokemon_details.dart';

class PokemonDetailsCache {
  final Map<String, FeaturedPokemonDetails> _cache = {};

  FeaturedPokemonDetails? get(String pokemonName) => _cache[pokemonName];

  void put(String pokemonName, FeaturedPokemonDetails details) {
    _cache[pokemonName] = details;
  }

  void retainOnly(Set<String> pokemonNames) {
    _cache.removeWhere((name, _) => !pokemonNames.contains(name));
  }

  void clear() => _cache.clear();

  int get length => _cache.length;
}
