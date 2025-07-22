class Item {
  final String? id;
  final String ownerId;
  final String title;
  final String description;
  final String category;
  final List<String> images;
  final String location;
  final double pricePerDay;
  final double deposit;
  final DateTime createdAt;
  final int stock;
  final int availableCount;

  Item({
    this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.category,
    required this.images,
    required this.location,
    required this.pricePerDay,
    required this.deposit,
    required this.createdAt,
    required this.stock,
    required this.availableCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'category': category,
      'images': images,
      'location': location,
      'pricePerDay': pricePerDay,
      'deposit': deposit,
      'createdAt': createdAt.toIso8601String(),
      'stock': stock,
      'availableCount': availableCount,
    };
  }

  factory Item.fromMap(String id, Map<String, dynamic> map) {
    return Item(
      id: id,
      ownerId: map['ownerId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      location: map['location'] ?? '',
      pricePerDay: (map['pricePerDay'] ?? 0).toDouble(),
      deposit: (map['deposit'] ?? 0).toDouble(),
      createdAt: DateTime.parse(map['createdAt']),
      stock: map['stock'] ?? 0,
      availableCount: map['availableCount'] ?? 0,
    );
  }
}
