import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/data/models/pokemon_species.dart';

void main() {
  test('PokemonSpecies prioriza descrição em português', () {
    final species = PokemonSpecies.fromJson({
      'id': 1,
      'name': 'bulbasaur',
      'flavor_text_entries': [
        {
          'flavor_text': 'English text.',
          'language': {'name': 'en'},
        },
        {
          'flavor_text': 'Texto em português.',
          'language': {'name': 'pt'},
        },
      ],
      'genera': [],
    });

    expect(species.description, 'Texto em português.');
    expect(species.descriptionLanguageCode, 'pt');
  });

  test('PokemonSpecies marca fallback em inglês para tradução', () {
    final species = PokemonSpecies.fromJson({
      'id': 1,
      'name': 'bulbasaur',
      'flavor_text_entries': [
        {
          'flavor_text': 'English only text.',
          'language': {'name': 'en'},
        },
      ],
      'genera': [],
    });

    expect(species.description, 'English only text.');
    expect(species.descriptionLanguageCode, 'en');
  });
}
