abstract final class AppRoutes {
  static const splash = '/splash';
  static const home = '/';
  static const pokemonDetail = '/pokemon/:id';

  static String pokemonDetailPath(int id) => '/pokemon/$id';
}
