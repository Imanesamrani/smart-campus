import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteModel {
  final String id;
  final String userId;
  final String roomId;
  final String roomName;
  final String building;
  final int capacity;
  final List<String> equipment;
  final DateTime addedAt;

  FavoriteModel({
    required this.id,
    required this.userId,
    required this.roomId,
    required this.roomName,
    required this.building,
    required this.capacity,
    required this.equipment,
    required this.addedAt,
  });

  // Convertir à partir de Firestore
  factory FavoriteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FavoriteModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      roomId: data['roomId'] ?? '',
      roomName: data['roomName'] ?? '',
      building: data['building'] ?? '',
      capacity: data['capacity'] ?? 0,
      equipment: List<String>.from(data['equipment'] ?? []),
      addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convertir vers Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'roomId': roomId,
      'roomName': roomName,
      'building': building,
      'capacity': capacity,
      'equipment': equipment,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }

  // Copier avec modifications
  FavoriteModel copyWith({
    String? id,
    String? userId,
    String? roomId,
    String? roomName,
    String? building,
    int? capacity,
    List<String>? equipment,
    DateTime? addedAt,
  }) {
    return FavoriteModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      roomId: roomId ?? this.roomId,
      roomName: roomName ?? this.roomName,
      building: building ?? this.building,
      capacity: capacity ?? this.capacity,
      equipment: equipment ?? this.equipment,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
