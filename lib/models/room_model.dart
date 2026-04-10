import 'package:cloud_firestore/cloud_firestore.dart';

class RoomModel {
  final String id;
  final String name;
  final String building;
  final int floor;
  final int capacity;
  final List<String> equipment;
  final String description;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? model3DUrl;

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
    this.model3DUrl,
  });

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
      model3DUrl: data['model3DUrl'],
    );
  }

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
      'model3DUrl': model3DUrl,
    };
  }

  RoomModel copyWith({
    String? id,
    String? name,
    String? building,
    int? floor,
    int? capacity,
    List<String>? equipment,
    String? description,
    bool? isAvailable,
    String? model3DUrl,
  }) {
    return RoomModel(
      id: id ?? this.id,
      name: name ?? this.name,
      building: building ?? this.building,
      floor: floor ?? this.floor,
      capacity: capacity ?? this.capacity,
      equipment: equipment ?? this.equipment,
      description: description ?? this.description,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      model3DUrl: model3DUrl ?? this.model3DUrl,
    );
  }

  @override
  String toString() =>
      'Room(id: $id, name: $name, building: $building, floor: $floor)';
}
