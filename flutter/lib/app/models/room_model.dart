class RoomModel {
  final int id;
  final String name;
  final String? description;
  final bool isPublic;
  final int? createdBy;
  final DateTime? createdAt;

  RoomModel({
    required this.id,
    required this.name,
    this.description,
    required this.isPublic,
    this.createdBy,
    this.createdAt,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      isPublic: json['is_public'] ?? true,
      createdBy: json['created_by'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'is_public': isPublic,
      'created_by': createdBy,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
