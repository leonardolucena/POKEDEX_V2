class PokemonNature {
  const PokemonNature({
    required this.name,
    required this.increasedStat,
    required this.decreasedStat,
  });

  final String name;
  final String? increasedStat;
  final String? decreasedStat;

  bool get hasEffect =>
      increasedStat != null &&
      decreasedStat != null &&
      increasedStat != decreasedStat;

  String get displayName =>
      '${name[0].toUpperCase()}${name.substring(1)}';

  NatureModifier modifierFor(String statKey) {
    if (!hasEffect) return NatureModifier.none;
    if (statKey == increasedStat) return NatureModifier.boosted;
    if (statKey == decreasedStat) return NatureModifier.lowered;
    return NatureModifier.none;
  }

  int applyToStat(String statKey, int baseValue) {
    if (!hasEffect || statKey == 'hp') return baseValue;
    if (statKey == increasedStat) return (baseValue * 1.1).floor();
    if (statKey == decreasedStat) return (baseValue * 0.9).floor();
    return baseValue;
  }

  static PokemonNature forPokemonId(int pokemonId) {
    return pokemonNatures[pokemonId % pokemonNatures.length];
  }
}

enum NatureModifier { none, boosted, lowered }

const pokemonNatures = [
  PokemonNature(name: 'hardy', increasedStat: 'attack', decreasedStat: 'attack'),
  PokemonNature(name: 'lonely', increasedStat: 'attack', decreasedStat: 'defense'),
  PokemonNature(name: 'brave', increasedStat: 'attack', decreasedStat: 'speed'),
  PokemonNature(name: 'adamant', increasedStat: 'attack', decreasedStat: 'special-attack'),
  PokemonNature(name: 'naughty', increasedStat: 'attack', decreasedStat: 'special-defense'),
  PokemonNature(name: 'bold', increasedStat: 'defense', decreasedStat: 'attack'),
  PokemonNature(name: 'docile', increasedStat: 'defense', decreasedStat: 'defense'),
  PokemonNature(name: 'relaxed', increasedStat: 'defense', decreasedStat: 'speed'),
  PokemonNature(name: 'impish', increasedStat: 'defense', decreasedStat: 'special-attack'),
  PokemonNature(name: 'lax', increasedStat: 'defense', decreasedStat: 'special-defense'),
  PokemonNature(name: 'timid', increasedStat: 'speed', decreasedStat: 'attack'),
  PokemonNature(name: 'hasty', increasedStat: 'speed', decreasedStat: 'defense'),
  PokemonNature(name: 'serious', increasedStat: 'speed', decreasedStat: 'speed'),
  PokemonNature(name: 'jolly', increasedStat: 'speed', decreasedStat: 'special-attack'),
  PokemonNature(name: 'naive', increasedStat: 'speed', decreasedStat: 'special-defense'),
  PokemonNature(name: 'modest', increasedStat: 'special-attack', decreasedStat: 'attack'),
  PokemonNature(name: 'mild', increasedStat: 'special-attack', decreasedStat: 'defense'),
  PokemonNature(name: 'quiet', increasedStat: 'special-attack', decreasedStat: 'speed'),
  PokemonNature(name: 'bashful', increasedStat: 'special-attack', decreasedStat: 'special-attack'),
  PokemonNature(name: 'rash', increasedStat: 'special-attack', decreasedStat: 'special-defense'),
  PokemonNature(name: 'calm', increasedStat: 'special-defense', decreasedStat: 'attack'),
  PokemonNature(name: 'gentle', increasedStat: 'special-defense', decreasedStat: 'defense'),
  PokemonNature(name: 'sassy', increasedStat: 'special-defense', decreasedStat: 'speed'),
  PokemonNature(name: 'careful', increasedStat: 'special-defense', decreasedStat: 'special-attack'),
  PokemonNature(name: 'quirky', increasedStat: 'special-defense', decreasedStat: 'special-defense'),
];
