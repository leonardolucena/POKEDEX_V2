import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:pokedex/core/constants/api_constants.dart';
import 'package:pokedex/data/models/pokemon.dart';
import 'package:pokedex/data/models/pokemon_list_item.dart';
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
    Future.microtask(refresh);
    return const PokemonListState(isLoading: true);
  }

  Future<void> refresh() async {
    _offset = 0;
    state = const PokemonListState(isLoading: true);

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
      state = PokemonListState(error: error);
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
