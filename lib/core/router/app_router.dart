import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex/core/router/app_routes.dart';
import 'package:pokedex/presentation/pages/pokemon_detail_page.dart';
import 'package:pokedex/presentation/pages/pokemon_list_page.dart';
import 'package:pokedex/presentation/pages/splash_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const PokemonListPage(),
      ),
      GoRoute(
        path: AppRoutes.pokemonDetail,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return PokemonDetailPage(pokemonId: id);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Página não encontrada')),
      body: Center(
        child: Text(state.error?.toString() ?? 'Rota inválida.'),
      ),
    ),
  );
});
