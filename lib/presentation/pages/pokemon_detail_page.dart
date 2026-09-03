import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex/providers/pokemon_providers.dart';

class PokemonDetailPage extends ConsumerWidget {
  const PokemonDetailPage({
    super.key,
    required this.pokemonId,
  });

  final int pokemonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPokemon = ref.watch(pokemonDetailProvider('$pokemonId'));

    return Scaffold(
      appBar: AppBar(
        title: asyncPokemon.maybeWhen(
          data: (pokemon) => Text(
            pokemon.name[0].toUpperCase() + pokemon.name.substring(1),
          ),
          orElse: () => const Text('Detalhes'),
        ),
      ),
      body: asyncPokemon.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(error.toString(), textAlign: TextAlign.center),
          ),
        ),
        data: (pokemon) => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            if (pokemon.imageUrl != null)
              Image.network(
                pokemon.imageUrl!,
                height: 220,
                fit: BoxFit.contain,
              ),
            const SizedBox(height: 24),
            Text(
              '#${pokemon.id.toString().padLeft(3, '0')}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: pokemon.types
                  .map(
                    (type) => Chip(
                      label: Text(type[0].toUpperCase() + type.substring(1)),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            _InfoRow(
              label: 'Altura',
              value: '${pokemon.height / 10} m',
            ),
            _InfoRow(
              label: 'Peso',
              value: '${pokemon.weight / 10} kg',
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleSmall),
          Text(value),
        ],
      ),
    );
  }
}
