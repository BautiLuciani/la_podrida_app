class Player {
  const Player({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  Player copyWith({
    String? id,
    String? name,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}
