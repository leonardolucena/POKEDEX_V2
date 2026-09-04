import 'package:flutter/material.dart';
import 'package:pokedex/core/constants/pokemon_type_colors.dart';

class PokemonTypeChip extends StatelessWidget {
  const PokemonTypeChip({
    super.key,
    required this.type,
  });

  final String type;

  @override
  Widget build(BuildContext context) {
    final color = PokemonTypeColors.forType(type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF1F1F1F),
          width: 1,
        ),
      ),
      child: Text(
        PokemonTypeColors.displayName(type),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
      ),
    );
  }
}
