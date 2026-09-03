import 'package:pokedex/data/models/pokemon.dart';
import 'package:pokedex/data/models/pokemon_list_response.dart';
import 'package:pokedex/data/services/pokeapi_service.dart';

class PokemonRepository {
  const PokemonRepository({required PokeApiService service}) : _service = service;

  final PokeApiService _service;

  Future<PokemonListResponse> fetchPokemonList({
    int limit = 20,
    int offset = 0,
  }) {
    return _service.fetchPokemonList(limit: limit, offset: offset);
  }

  Future<Pokemon> fetchPokemon(String idOrName) {
    return _service.fetchPokemon(idOrName);
  }
}
