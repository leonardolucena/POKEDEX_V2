import 'package:pokedex/data/models/pokemon_stats.dart';

class PokemonAbility {
  const PokemonAbility({
    required this.name,
    required this.isHidden,
  });

  final String name;
  final bool isHidden;

  String get displayName => name
      .split('-')
      .map(
        (part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1)}',
      )
      .join(' ');
}

class Pokemon {
  const Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
    required this.height,
    required this.weight,
    required this.stats,
    required this.abilities,
  });

  final int id;
  final String name;
  final String? imageUrl;
  final List<String> types;
  final int height;
  final int weight;
  final PokemonStats stats;
  final List<PokemonAbility> abilities;

  double get heightMeters => height / 10;
  double get weightKg => weight / 10;

  String get formattedHeight {
    final meters = heightMeters;
    return '${meters.toStringAsFixed(meters.truncateToDouble() == meters ? 0 : 1)} m';
  }

  String get formattedWeight {
    final kg = weightKg;
    return '${kg.toStringAsFixed(kg.truncateToDouble() == kg ? 0 : 1)} kg';
  }

  String get displayName => name
      .split('-')
      .map(
        (part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1)}',
      )
      .join('-');

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final sprites = json['sprites'] as Map<String, dynamic>?;
    final other = sprites?['other'] as Map<String, dynamic>?;
    final artwork = other?['official-artwork'] as Map<String, dynamic>?;

    return Pokemon(
      id: json['id'] as int,
      name: json['name'] as String,
      imageUrl: artwork?['front_default'] as String? ??
          sprites?['front_default'] as String?,
      types: (json['types'] as List<dynamic>)
          .map((entry) => (entry as Map<String, dynamic>)['type']
              as Map<String, dynamic>)
          .map((type) => type['name'] as String)
          .toList(),
      height: json['height'] as int,
      weight: json['weight'] as int,
      stats: PokemonStats.fromJson(json['stats'] as List<dynamic>),
      abilities: (json['abilities'] as List<dynamic>? ?? [])
          .map((entry) {
            final map = entry as Map<String, dynamic>;
            final ability = map['ability'] as Map<String, dynamic>;
            return PokemonAbility(
              name: ability['name'] as String,
              isHidden: map['is_hidden'] as bool? ?? false,
            );
          })
          .toList(),
    );
  }
}
