class MarketItem {
  final int? id;
  final String name;
  final int? priceCentavos; // Preço em centavos para precisão
  final int quantity;
  final String? description;
  final String? category;

  MarketItem({
    this.id,
    required this.name,
    this.priceCentavos,
    required this.quantity,
    this.description,
    this.category,
  });

  // Getter para compatibilidade com código existente
  double? get price => priceCentavos != null ? priceCentavos! / 100.0 : null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price, // Mantém compatibilidade salvando como double
      'quantity': quantity,
      'description': description,
      'category': category,
    };
  }

  factory MarketItem.fromMap(Map<String, dynamic> map) {
    // Converte double para centavos se o preço existir
    int? centavos;
    if (map['price'] != null) {
      double priceValue = map['price'] is int
          ? (map['price'] as int).toDouble()
          : map['price'] as double;
      centavos = (priceValue * 100).round();
    }

    return MarketItem(
      id: map['id'],
      name: map['name'],
      priceCentavos: centavos,
      quantity: map['quantity'],
      description: map['description'],
      category: map['category'],
    );
  }
}
