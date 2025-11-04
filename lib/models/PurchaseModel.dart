class Purchase {
  final int? id;
  final String name;
  final DateTime date;
  final List<int> itemIds;
  final double totalValue;
  final Map<int, bool> isAdded;

  Purchase({
    this.id,
    required this.name,
    required this.date,
    required this.itemIds,
    required this.totalValue,
    required this.isAdded,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'itemIds': itemIds.join(','),
      'totalValue': totalValue,
      'isAdded': isAdded.entries.map((e) => '${e.key}:${e.value ? 1 : 0}').join(','),
    };
  }

  factory Purchase.fromMap(Map<String, dynamic> map) {
    final isAddedMap = <int, bool>{};

    if (map['isAdded'] != null && (map['isAdded'] as String).isNotEmpty) {
      for (var pair in (map['isAdded'] as String).split(',')) {
        final parts = pair.split(':');
        if (parts.length == 2) {
          isAddedMap[int.parse(parts[0])] = parts[1] == '1';
        }
      }
    }

    return Purchase(
      id: map['id'],
      name: map['name'],
      date: DateTime.parse(map['date']),
      itemIds: (map['itemIds'] as String)
          .split(',')
          .where((e) => e.isNotEmpty)
          .map(int.parse)
          .toList(),
      totalValue: map['totalValue'] is int
          ? (map['totalValue'] as int).toDouble()
          : map['totalValue'] as double,
      isAdded: isAddedMap,
    );
  }
}
