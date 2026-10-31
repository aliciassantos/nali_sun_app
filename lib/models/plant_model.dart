// Dados da planta

class PlantModel {
  final String id;
  final DateTime createdAt;
  final String userId;
  final String name;
  final String species;
  final String? imagePath;
  final String wateringFrequencyDays;
  final DateTime? lastWateredAt;
  final String luminosity;

  PlantModel({
    required this.id,
    required this.createdAt,
    required this.userId,
    required this.name,
    required this.species,
    this.imagePath,
    required this.wateringFrequencyDays,
    this.lastWateredAt,
    required this.luminosity,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(), // Como não é aninhado (nullable), não precisa de verificação nula
      'user_id': userId,
      'name': name,
      'species': species,
      'image_path': imagePath,
      'watering_frequency_days': wateringFrequencyDays,
      'last_watered_at': lastWateredAt?.toIso8601String(), // Verificação nula usando o operador ?
      'luminosity': luminosity,
    };
  }

  factory PlantModel.fromMap(Map<String, dynamic> map) {
    return PlantModel(
      id: map['id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      userId: map['user_id'] as String,
      name: map['name'] as String,
      species: map['species'] as String,
      imagePath: map['image_path'] as String?,
      wateringFrequencyDays: map['watering_frequency_days'].toString(), // O .toString() garante que não dê erro caso o banco retorne um inteiro
      lastWateredAt: map['last_watered_at'] != null 
          ? DateTime.parse(map['last_watered_at'] as String) 
          : null,
      luminosity: map['luminosity'] as String,
    );
  }
}