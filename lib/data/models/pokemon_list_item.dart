class PokemonListItem {
  const PokemonListItem({
    required this.name,
    required this.url,
  });

  final String name;
  final String url;

  int? get id {
    final segments = Uri.parse(url).pathSegments;
    if (segments.isEmpty) return null;
    return int.tryParse(segments.last);
  }

  factory PokemonListItem.fromJson(Map<String, dynamic> json) {
    return PokemonListItem(
      name: json['name'] as String,
      url: json['url'] as String,
    );
  }
}
