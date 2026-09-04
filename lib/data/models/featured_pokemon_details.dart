import 'package:pokedex/data/models/pokemon.dart';

class FeaturedPokemonDetails {
  const FeaturedPokemonDetails({
    required this.pokemon,
    required this.description,
    required this.genus,
  });

  final Pokemon pokemon;
  final String description;
  final String? genus;
}
