import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:pokedex/core/constants/api_constants.dart';
import 'package:pokedex/data/cache/pokemon_details_cache.dart';
import 'package:pokedex/data/models/featured_pokemon_details.dart';
import 'package:pokedex/data/models/pokemon.dart';
import 'package:pokedex/data/models/pokemon_list_item.dart';
import 'package:pokedex/data/repositories/pokemon_repository.dart';
import 'package:pokedex/data/services/pokeapi_service.dart';
import 'package:pokedex/data/services/pokemon_sprite_preloader.dart';

export 'package:pokedex/data/models/featured_pokemon_details.dart';

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final pokeApiServiceProvider = Provider<PokeApiService>((ref) {
  return PokeApiService(client: ref.watch(httpClientProvider));
});

final pokemonDetailsCacheProvider = Provider<PokemonDetailsCache>((ref) {
  return PokemonDetailsCache();
});

final pokemonRepositoryProvider = Provider<PokemonRepository>((ref) {
  return PokemonRepository(
    service: ref.watch(pokeApiServiceProvider),
    cache: ref.watch(pokemonDetailsCacheProvider),
  );
});

typedef PokemonSpritePreloader = Future<void> Function(String pokemonName);

final pokemonSpritePreloaderProvider = Provider<PokemonSpritePreloader>((ref) {
  return preloadAnimatedSprite;
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

enum PokedexNavigationDirection { forward, backward }

class PokedexNavigationState {
  const PokedexNavigationState({
    this.index = 0,
    this.direction = PokedexNavigationDirection.forward,
  });

  final int index;
  final PokedexNavigationDirection direction;

  PokedexNavigationState copyWith({
    int? index,
    PokedexNavigationDirection? direction,
  }) {
    return PokedexNavigationState(
      index: index ?? this.index,
      direction: direction ?? this.direction,
    );
  }
}

class PokedexNavigationNotifier extends Notifier<PokedexNavigationState> {
  static const _scrollStep = 32.0;
  static const _preloadAhead = 5;

  @override
  PokedexNavigationState build() => const PokedexNavigationState();

  Future<void> selectNext() async {
    final listState = ref.read(pokemonListNotifierProvider);
    if (listState.items.isEmpty) return;

    if (state.index < listState.items.length - 1) {
      state = state.copyWith(
        index: state.index + 1,
        direction: PokedexNavigationDirection.forward,
      );
      _preloadNextPage();
      preloadNearbyDetails();
      return;
    }

    if (!listState.hasMore || listState.isLoadingMore) return;

    await ref.read(pokemonListNotifierProvider.notifier).loadMore();
    final updated = ref.read(pokemonListNotifierProvider);
    if (state.index < updated.items.length - 1) {
      state = state.copyWith(
        index: state.index + 1,
        direction: PokedexNavigationDirection.forward,
      );
      preloadNearbyDetails();
    }
  }

  void selectPrevious() {
    if (state.index > 0) {
      state = state.copyWith(
        index: state.index - 1,
        direction: PokedexNavigationDirection.backward,
      );
      preloadNearbyDetails();
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
    if (state.index >= listState.items.length - 3 &&
        listState.hasMore &&
        !listState.isLoadingMore) {
      ref.read(pokemonListNotifierProvider.notifier).loadMore();
    }
  }

  void preloadNearbyDetails() {
    final listState = ref.read(pokemonListNotifierProvider);
    if (listState.items.isEmpty) return;

    final safeIndex = state.index.clamp(0, listState.items.length - 1);
    final names = <String>{};

    for (var offset = 0; offset <= _preloadAhead; offset++) {
      final index = safeIndex + offset;
      if (index >= listState.items.length) break;
      names.add(listState.items[index].name);
    }

    final repository = ref.read(pokemonRepositoryProvider);
    repository.retainCachedFeaturedDetails(names);
    repository.preloadFeaturedPokemonDetails(names.toList());
  }
}

final pokedexNavigationProvider =
    NotifierProvider<PokedexNavigationNotifier, PokedexNavigationState>(
  PokedexNavigationNotifier.new,
);

final featuredPokemonProvider = FutureProvider<FeaturedPokemonDetails>((ref) async {
  final selectedIndex = ref.watch(pokedexNavigationProvider).index;
  final listState = ref.watch(pokemonListNotifierProvider);

  if (listState.items.isEmpty) {
    throw listState.error ?? Exception('Não foi possível carregar os Pokémon.');
  }

  final safeIndex = selectedIndex.clamp(0, listState.items.length - 1);
  final pokemonName = listState.items[safeIndex].name;
  final repository = ref.read(pokemonRepositoryProvider);

  return repository.fetchFeaturedPokemonDetails(pokemonName);
});

Future<void> preloadPokedexData(WidgetRef ref) async {
  await ref.read(pokemonListNotifierProvider.notifier).refresh();

  final listState = ref.read(pokemonListNotifierProvider);
  if (listState.items.isEmpty) {
    throw listState.error ?? Exception('Não foi possível carregar os Pokémon.');
  }

  ref.invalidate(featuredPokemonProvider);
  final featured = await ref.read(featuredPokemonProvider.future);
  await ref.read(pokemonSpritePreloaderProvider)(featured.pokemon.name);
  ref.read(pokedexNavigationProvider.notifier).preloadNearbyDetails();
}

Future<void> reloadPokedexData(WidgetRef ref) async {
  ref.read(pokemonDetailsCacheProvider).clear();
  await ref.read(pokemonListNotifierProvider.notifier).refresh();
  ref.invalidate(featuredPokemonProvider);

  final listState = ref.read(pokemonListNotifierProvider);
  if (listState.items.isNotEmpty) {
    final featured = await ref.read(featuredPokemonProvider.future);
    await ref.read(pokemonSpritePreloaderProvider)(featured.pokemon.name);
    ref.read(pokedexNavigationProvider.notifier).preloadNearbyDetails();
  }
}
