import 'package:pokedex/data/models/pokemon_nature.dart';

class PokemonStats {
  const PokemonStats({
    required this.hp,
    required this.attack,
    required this.defense,
    required this.specialAttack,
    required this.specialDefense,
    required this.speed,
  });

  final int hp;
  final int attack;
  final int defense;
  final int specialAttack;
  final int specialDefense;
  final int speed;

  static const chartLabels = [
    'HP',
    'Atk',
    'Def',
    'Spe',
    'SpD',
    'SpA',
  ];

  static const chartStatKeys = [
    'hp',
    'attack',
    'defense',
    'speed',
    'special-defense',
    'special-attack',
  ];

  int valueForStatKey(String statKey) {
    return switch (statKey) {
      'hp' => hp,
      'attack' => attack,
      'defense' => defense,
      'speed' => speed,
      'special-defense' => specialDefense,
      'special-attack' => specialAttack,
      _ => 0,
    };
  }

  List<int> chartValuesWithNature(PokemonNature nature) {
    return chartStatKeys
        .map((key) => nature.applyToStat(key, valueForStatKey(key)))
        .toList();
  }

  List<int> get chartValues => [
        hp,
        attack,
        defense,
        speed,
        specialDefense,
        specialAttack,
      ];

  factory PokemonStats.fromJson(List<dynamic> json) {
    final values = <String, int>{};

    for (final entry in json) {
      final map = entry as Map<String, dynamic>;
      final stat = map['stat'] as Map<String, dynamic>;
      values[stat['name'] as String] = map['base_stat'] as int;
    }

    return PokemonStats(
      hp: values['hp'] ?? 0,
      attack: values['attack'] ?? 0,
      defense: values['defense'] ?? 0,
      specialAttack: values['special-attack'] ?? 0,
      specialDefense: values['special-defense'] ?? 0,
      speed: values['speed'] ?? 0,
    );
  }
}
