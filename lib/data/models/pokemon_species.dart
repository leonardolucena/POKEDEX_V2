class PokemonSpecies {
  const PokemonSpecies({
    required this.id,
    required this.name,
    required this.description,
    required this.descriptionLanguageCode,
    required this.genus,
  });

  final int id;
  final String name;
  final String description;
  final String? descriptionLanguageCode;
  final String? genus;

  factory PokemonSpecies.fromJson(Map<String, dynamic> json) {
    final entries = json['flavor_text_entries'] as List<dynamic>? ?? [];
    final genera = json['genera'] as List<dynamic>? ?? [];

    String? pickLocalizedText(
      List<dynamic> source,
      String textKey,
      String languageCode,
    ) {
      for (final entry in source.reversed) {
        final map = entry as Map<String, dynamic>;
        final language = map['language'] as Map<String, dynamic>?;
        if (language?['name'] == languageCode) {
          final text = map[textKey] as String?;
          if (text != null && text.trim().isNotEmpty) {
            return _cleanFlavorText(text);
          }
        }
      }
      return null;
    }

    final portugueseDescription =
        pickLocalizedText(entries, 'flavor_text', 'pt');
    final englishDescription = pickLocalizedText(entries, 'flavor_text', 'en');

    final description = portugueseDescription ??
        englishDescription ??
        'Descrição indisponível.';
    final descriptionLanguageCode = portugueseDescription != null
        ? 'pt'
        : englishDescription != null
            ? 'en'
            : null;

    final genus =
        pickLocalizedText(genera, 'genus', 'pt') ??
            pickLocalizedText(genera, 'genus', 'en');

    return PokemonSpecies(
      id: json['id'] as int,
      name: json['name'] as String,
      description: description,
      descriptionLanguageCode: descriptionLanguageCode,
      genus: genus,
    );
  }
}

String _cleanFlavorText(String text) {
  return text
      .replaceAll('\n', ' ')
      .replaceAll('\f', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
