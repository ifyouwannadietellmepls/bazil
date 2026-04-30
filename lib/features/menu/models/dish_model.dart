class Dish {
  final String id;
  final String name;
  final String description;
  final int weight;
  final int price;
  final String category;
  final List<String> tags;

  const Dish({
    required this.id,
    required this.name,
    required this.description,
    required this.weight,
    required this.price,
    required this.category,
    this.tags = const [],
  });

  bool get isVegetarian => tags.contains('vegetarian');
  bool get isSpicy => tags.contains('spicy');
  bool get isPopular => tags.contains('popular');
  
  String get priceFormatted => '$price ₽';
  String get weightFormatted => weight > 0 ? '$weight г' : '';
}