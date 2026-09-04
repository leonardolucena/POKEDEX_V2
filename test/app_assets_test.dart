import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/constants/app_assets.dart';

void main() {
  test('backgroundForTypes prioriza água, fogo, gelo e voador', () {
    expect(AppAssets.backgroundForTypes(['grass', 'poison']), AppAssets.campo);
    expect(AppAssets.backgroundForTypes(['fire', 'flying']), AppAssets.fogo);
    expect(AppAssets.backgroundForTypes(['normal', 'flying']), AppAssets.voador);
    expect(AppAssets.backgroundForTypes(['water']), AppAssets.agua);
    expect(AppAssets.backgroundForTypes(['ice']), AppAssets.gelo);
  });
}
