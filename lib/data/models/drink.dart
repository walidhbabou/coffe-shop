class Drink {
  final String name;
  final String imagePath;
  final bool isFavorite;
  final double? price;
  final String? description;

  Drink({
    required this.name,
    required this.imagePath,
    this.isFavorite = false,
    this.price,
    this.description,
  });

  factory Drink.fromJson(Map<String, dynamic> json) {
    return Drink(
      name: json['title'] ?? '', // Utilise 'title' de l'API
      imagePath: json['image'] ?? '',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : null,
      description: json['description'],
      isFavorite: json['isFavorite'] ?? false,
    );
  }
}
