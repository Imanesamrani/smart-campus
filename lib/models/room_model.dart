import 'package:cloud_firestore/cloud_firestore.dart';

class RoomModel {
  final String id;
  final String name; // Nom de la salle (ex: "Amphi 1", "Salle 201")
  final String building; // Bâtiment (ex: "Bâtiment A", "Bloc 2")
  final int floor; // Étage
  final int capacity; // Capacité d'accueil
  final List<String> equipment; // Équipements disponibles
  final String description; // Description additionnelle
  final bool isAvailable; // Disponibilité de la salle
  final DateTime createdAt;
  final DateTime updatedAt;

  RoomModel({
    required this.id,
    required this.name,
    required this.building,
    required this.floor,
    required this.capacity,
    required this.equipment,
    required this.description,
    this.isAvailable = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convertir un document Firestore en RoomModel
  factory RoomModel.fromFirestore(Map<String, dynamic> data, String roomId) {
    return RoomModel(
      id: roomId,
      name: data['name'] ?? '',
      building: data['building'] ?? '',
      floor: data['floor'] ?? 0,
      capacity: data['capacity'] ?? 0,
      equipment: List<String>.from(data['equipment'] ?? []),
      description: data['description'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Convertir RoomModel en Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'building': building,
      'floor': floor,
      'capacity': capacity,
      'equipment': equipment,
      'description': description,
      'isAvailable': isAvailable,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Créer une copie avec des modifications
  RoomModel copyWith({
    String? name,
    String? building,
    int? floor,
    int? capacity,
    List<String>? equipment,
    String? description,
    bool? isAvailable,
  }) {
    return RoomModel(
      id: id,
      name: name ?? this.name,
      building: building ?? this.building,
      floor: floor ?? this.floor,
      capacity: capacity ?? this.capacity,
      equipment: equipment ?? this.equipment,
      description: description ?? this.description,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  String toString() =>
      'Room(id: $id, name: $name, building: $building, floor: $floor)';
}