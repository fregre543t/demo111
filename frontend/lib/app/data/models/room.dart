class Room {
  const Room({
    required this.id,
    required this.name,
    required this.description,
    required this.active,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String description;
  final bool active;
  final DateTime createdAt;

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      active: json['active'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
