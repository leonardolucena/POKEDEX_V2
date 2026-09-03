import 'pokemon_list_item.dart';

class PokemonListResponse {
  const PokemonListResponse({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  final int count;
  final String? next;
  final String? previous;
  final List<PokemonListItem> results;

  factory PokemonListResponse.fromJson(Map<String, dynamic> json) {
    return PokemonListResponse(
      count: json['count'] as int,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List<dynamic>)
          .map((item) => PokemonListItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
