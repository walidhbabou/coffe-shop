class Drink {
  final String id;
  final String name;
  final String imagePath;
  bool isFavorite;
  final double? price;
  final String? description;

  Drink({
    required this.id,
    required this.name,
    required this.imagePath,
    this.isFavorite = false,
    this.price,
    this.description,
  });

  factory Drink.fromJson(Map<String, dynamic> json) {
    // Convertir l'id en String, qu'il soit int ou String dans le JSON
    final id = json['id'];
    String idString;
    if (id is int) {
      idString = id.toString();
    } else if (id is String) {
      idString = id;
    } else {
      idString = ''; // Valeur par défaut si l'id n'est ni int ni String
    }

    return Drink(
      id: idString,
      name: json['title'] ?? '',
      imagePath: json['image'] ?? '',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : null,
      description: json['description'],
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': name,
      'image': imagePath,
      'price': price,
      'description': description,
      'isFavorite': isFavorite,
    };
  }
}
