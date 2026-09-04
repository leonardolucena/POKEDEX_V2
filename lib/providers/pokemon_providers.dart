import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:pokedex/core/constants/api_constants.dart';
import 'package:pokedex/data/models/pokemon.dart';
import 'package:pokedex/data/models/pokemon_list_item.dart';
import 'package:pokedex/data/models/pokemon_species.dart';
import 'package:pokedex/data/repositories/pokemon_repository.dart';
import 'package:pokedex/data/services/pokeapi_service.dart';

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final pokeApiServiceProvider = Provider<PokeApiService>((ref) {
  return PokeApiService(client: ref.watch(httpClientProvider));
});

final pokemonRepositoryProvider = Provider<PokemonRepository>((ref) {
  return PokemonRepository(service: ref.watch(pokeApiServiceProvider));
});

class PokemonListState {
  const PokemonListState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.hasMore = true,
    this.totalCount = 0,
  });

  final List<PokemonListItem> items;
  final bool isLoading;
  final bool isLoadingMore;
  final Object? error;
  final bool hasMore;
  final int totalCount;

  PokemonListState copyWith({
    List<PokemonListItem>? items,
    bool? isLoading,
    bool? isLoadingMore,
    Object? error,
    bool clearError = false,
    bool? hasMore,
    int? totalCount,
  }) {
    return PokemonListState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : error ?? this.error,
      hasMore: hasMore ?? this.hasMore,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

class PokemonListNotifier extends Notifier<PokemonListState> {
  int _offset = 0;

  @override
  PokemonListState build() {
    return const PokemonListState();
  }

  Future<void> refresh() async {
    _offset = 0;
    final previousItems = state.items;
    state = PokemonListState(
      isLoading: true,
      items: previousItems,
    );

    try {
      final response = await ref.read(pokemonRepositoryProvider).fetchPokemonList(
            limit: ApiConstants.defaultPageSize,
            offset: _offset,
          );

      _offset = response.results.length;
      state = PokemonListState(
        items: response.results,
        totalCount: response.count,
        hasMore: _offset < response.count,
      );
    } catch (error) {
      state = PokemonListState(
        items: previousItems,
        error: error,
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true, clearError: true);

    try {
      final response = await ref.read(pokemonRepositoryProvider).fetchPokemonList(
            limit: ApiConstants.defaultPageSize,
            offset: _offset,
          );

      _offset += response.results.length;
      state = PokemonListState(
        items: [...state.items, ...response.results],
        totalCount: response.count,
        hasMore: _offset < response.count,
      );
    } catch (error) {
      state = state.copyWith(isLoadingMore: false, error: error);
    }
  }
}

final pokemonListNotifierProvider =
    NotifierProvider<PokemonListNotifier, PokemonListState>(
  PokemonListNotifier.new,
);

final pokemonDetailProvider =
    FutureProvider.family<Pokemon, String>((ref, idOrName) {
  return ref.watch(pokemonRepositoryProvider).fetchPokemon(idOrName);
});

final descriptionScrollControllerProvider = Provider<ScrollController>((ref) {
  final controller = ScrollController();
  ref.onDispose(controller.dispose);
  return controller;
});

class PokedexNavigationNotifier extends Notifier<int> {
  static const _scrollStep = 32.0;

  @override
  int build() => 0;

  Future<void> selectNext() async {
    final listState = ref.read(pokemonListNotifierProvider);
    if (listState.items.isEmpty) return;

    if (state < listState.items.length - 1) {
      state = state + 1;
      _preloadNextPage();
      return;
    }

    if (!listState.hasMore || listState.isLoadingMore) return;

    await ref.read(pokemonListNotifierProvider.notifier).loadMore();
    final updated = ref.read(pokemonListNotifierProvider);
    if (state < updated.items.length - 1) {
      state = state + 1;
    }
  }

  void selectPrevious() {
    if (state > 0) {
      state = state - 1;
    }
  }

  void scrollDescriptionUp() {
    _scrollBy(-_scrollStep);
  }

  void scrollDescriptionDown() {
    _scrollBy(_scrollStep);
  }

  void _scrollBy(double delta) {
    final controller = ref.read(descriptionScrollControllerProvider);
    if (!controller.hasClients) return;

    final target = (controller.offset + delta)
        .clamp(0.0, controller.position.maxScrollExtent);

    controller.animateTo(
      target,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
    );
  }

  void _preloadNextPage() {
    final listState = ref.read(pokemonListNotifierProvider);
    if (state >= listState.items.length - 3 &&
        listState.hasMore &&
        !listState.isLoadingMore) {
      ref.read(pokemonListNotifierProvider.notifier).loadMore();
    }
  }
}

final pokedexNavigationProvider =
    NotifierProvider<PokedexNavigationNotifier, int>(
  PokedexNavigationNotifier.new,
);

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

final featuredPokemonProvider = FutureProvider<FeaturedPokemonDetails>((ref) async {
  final selectedIndex = ref.watch(pokedexNavigationProvider);
  final listState = ref.watch(pokemonListNotifierProvider);

  if (listState.items.isEmpty) {
    throw listState.error ?? Exception('Não foi possível carregar os Pokémon.');
  }

  final safeIndex = selectedIndex.clamp(0, listState.items.length - 1);
  final pokemonName = listState.items[safeIndex].name;
  final repository = ref.read(pokemonRepositoryProvider);

  final results = await Future.wait([
    repository.fetchPokemon(pokemonName),
    repository.fetchPokemonSpecies(pokemonName),
  ]);

  final pokemon = results[0] as Pokemon;
  final species = results[1] as PokemonSpecies;

  return FeaturedPokemonDetails(
    pokemon: pokemon,
    description: species.description,
    genus: species.genus,
  );
});

Future<void> preloadPokedexData(WidgetRef ref) async {
  await ref.read(pokemonListNotifierProvider.notifier).refresh();

  final listState = ref.read(pokemonListNotifierProvider);
  if (listState.items.isEmpty) {
    throw listState.error ?? Exception('Não foi possível carregar os Pokémon.');
  }

  ref.invalidate(featuredPokemonProvider);
  await ref.read(featuredPokemonProvider.future);
}

Future<void> reloadPokedexData(WidgetRef ref) async {
  await ref.read(pokemonListNotifierProvider.notifier).refresh();
  ref.invalidate(featuredPokemonProvider);

  final listState = ref.read(pokemonListNotifierProvider);
  if (listState.items.isNotEmpty) {
    await ref.read(featuredPokemonProvider.future);
  }
}
