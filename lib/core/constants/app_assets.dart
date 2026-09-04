abstract final class AppAssets {
  static const String imagesPath = 'assets/images';

  static const String campo = '$imagesPath/campo.png';
  static const String agua = '$imagesPath/agua.png';
  static const String fogo = '$imagesPath/fogo.png';
  static const String gelo = '$imagesPath/gelo.png';
  static const String voador = '$imagesPath/voador.png';

  static String backgroundForTypes(List<String> types) {
    if (types.isEmpty) return campo;

    const prioritizedTypes = ['water', 'fire', 'ice', 'flying'];
    for (final type in prioritizedTypes) {
      if (types.contains(type)) {
        return _backgroundByType[type]!;
      }
    }

    return campo;
  }

  static const _backgroundByType = <String, String>{
    'water': agua,
    'fire': fogo,
    'ice': gelo,
    'flying': voador,
  };
}
