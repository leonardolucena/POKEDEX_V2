class PokemonSpecies {
  const PokemonSpecies({
    required this.id,
    required this.name,
    required this.description,
  });

  final int id;
  final String name;
  final String description;

  factory PokemonSpecies.fromJson(Map<String, dynamic> json) {
    final entries = json['flavor_text_entries'] as List<dynamic>? ?? [];

    String? pickDescription(String languageCode) {
      for (final entry in entries.reversed) {
        final map = entry as Map<String, dynamic>;
        final language = map['language'] as Map<String, dynamic>?;
        if (language?['name'] == languageCode) {
          final text = map['flavor_text'] as String?;
          if (text != null && text.trim().isNotEmpty) {
            return _cleanFlavorText(text);
          }
        }
      }
      return null;
    }

    final description =
        pickDescription('pt') ?? pickDescription('en') ?? 'Descrição indisponível.';

    return PokemonSpecies(
      id: json['id'] as int,
      name: json['name'] as String,
      description: description,
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
