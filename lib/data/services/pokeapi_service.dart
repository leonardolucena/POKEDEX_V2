import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pokedex/core/constants/api_constants.dart';
import 'package:pokedex/data/models/pokemon.dart';
import 'package:pokedex/data/models/pokemon_list_response.dart';

class PokeApiException implements Exception {
  PokeApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'PokeApiException($statusCode): $message';
}

class PokeApiService {
  PokeApiService({required http.Client client}) : _client = client;

  final http.Client _client;

  Future<PokemonListResponse> fetchPokemonList({
    int limit = ApiConstants.defaultPageSize,
    int offset = 0,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/pokemon?limit=$limit&offset=$offset',
    );
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw PokeApiException(
        'Falha ao buscar lista de Pokémon.',
        statusCode: response.statusCode,
      );
    }

    return PokemonListResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<Pokemon> fetchPokemon(String idOrName) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/pokemon/$idOrName');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw PokeApiException(
        'Pokémon não encontrado.',
        statusCode: response.statusCode,
      );
    }

    return Pokemon.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
