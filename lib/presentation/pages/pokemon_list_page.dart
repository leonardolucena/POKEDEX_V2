import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex/core/router/app_routes.dart';
import 'package:pokedex/data/models/pokemon_list_item.dart';
import 'package:pokedex/presentation/widgets/pokedex_device_header.dart';
import 'package:pokedex/providers/pokemon_providers.dart';

class PokemonListPage extends ConsumerWidget {
  const PokemonListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listState = ref.watch(pokemonListNotifierProvider);

    return Scaffold(
      backgroundColor: PokedexDeviceColors.backgroundRed,
      body: _buildBody(context, ref, listState),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    PokemonListState listState,
  ) {
    if (listState.isLoading && listState.items.isEmpty) {
      return const CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: PokedexDeviceHeader()),
          SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

    if (listState.error != null && listState.items.isEmpty) {
      return CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: PokedexDeviceHeader()),
          SliverFillRemaining(
            child: _ErrorView(
              message: listState.error.toString(),
              onRetry: () =>
                  ref.read(pokemonListNotifierProvider.notifier).refresh(),
            ),
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(pokemonListNotifierProvider.notifier).refresh(),
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: PokedexDeviceHeader()),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == listState.items.length) {
                  if (listState.isLoadingMore) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (!listState.hasMore) {
                    return const SizedBox(height: 24);
                  }

                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: OutlinedButton(
                      onPressed: () => ref
                          .read(pokemonListNotifierProvider.notifier)
                          .loadMore(),
                      child: const Text('Carregar mais'),
                    ),
                  );
                }

                return _PokemonListTile(item: listState.items[index]);
              },
              childCount: listState.items.length + 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _PokemonListTile extends StatelessWidget {
  const _PokemonListTile({required this.item});

  final PokemonListItem item;

  @override
  Widget build(BuildContext context) {
    final id = item.id;

    return Material(
      color: Colors.white,
      child: ListTile(
        leading: CircleAvatar(child: Text('#${id ?? '?'}')),
        title: Text(
          item.name[0].toUpperCase() + item.name.substring(1),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(item.url),
        trailing: const Icon(Icons.chevron_right),
        onTap: id == null
            ? null
            : () => context.push(AppRoutes.pokemonDetailPath(id)),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
