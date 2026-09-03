class Pokemon {
  const Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
    required this.height,
    required this.weight,
  });

  final int id;
  final String name;
  final String? imageUrl;
  final List<String> types;
  final int height;
  final int weight;

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final sprites = json['sprites'] as Map<String, dynamic>?;
    final other = sprites?['other'] as Map<String, dynamic>?;
    final artwork = other?['official-artwork'] as Map<String, dynamic>?;

    return Pokemon(
      id: json['id'] as int,
      name: json['name'] as String,
      imageUrl: artwork?['front_default'] as String? ??
          sprites?['front_default'] as String?,
      types: (json['types'] as List<dynamic>)
          .map((entry) => (entry as Map<String, dynamic>)['type']
              as Map<String, dynamic>)
          .map((type) => type['name'] as String)
          .toList(),
      height: json['height'] as int,
      weight: json['weight'] as int,
    );
  }
}
