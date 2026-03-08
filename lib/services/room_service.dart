import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room_model.dart';

class RoomService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'rooms';

  // 📌 CRÉER une nouvelle salle
  Future<String> createRoom(RoomModel room) async {
    try {
      final docRef = await _firestore.collection(_collection).add(room.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Erreur lors de la création de la salle: $e');
    }
  }

  // 📝 OBTENIR un salle par ID
  Future<RoomModel?> getRoomById(String roomId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(roomId).get();
      if (doc.exists) {
        return RoomModel.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la salle: $e');
    }
  }

  // 📋 OBTENIR toutes les salles
  Future<List<RoomModel>> getAllRooms() async {
    try {
      final querySnapshot = await _firestore.collection(_collection).get();
      return querySnapshot.docs
          .map((doc) => RoomModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des salles: $e');
    }
  }

  // 🏗️ OBTENIR les salles par bâtiment
  Future<List<RoomModel>> getRoomsByBuilding(String building) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('building', isEqualTo: building)
          .get();
      return querySnapshot.docs
          .map((doc) => RoomModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des salles: $e');
    }
  }

  // 🔍 RECHERCHER des salles par nom
  Future<List<RoomModel>> searchRooms(String query) async {
    try {
      final querySnapshot = await _firestore.collection(_collection).get();
      final rooms = querySnapshot.docs
          .map((doc) => RoomModel.fromFirestore(doc.data(), doc.id))
          .toList();

      // Filtrer les salles par nom ou bâtiment
      return rooms
          .where((room) =>
              room.name.toLowerCase().contains(query.toLowerCase()) ||
              room.building.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la recherche de salles: $e');
    }
  }

  // 🛠️ MODIFIER une salle
  Future<void> updateRoom(String roomId, RoomModel room) async {
    try {
      await _firestore.collection(_collection).doc(roomId).update(room.toFirestore());
    } catch (e) {
      throw Exception('Erreur lors de la modification de la salle: $e');
    }
  }

  // 🗑️ SUPPRIMER une salle
  Future<void> deleteRoom(String roomId) async {
    try {
      await _firestore.collection(_collection).doc(roomId).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la salle: $e');
    }
  }

  // 🔴 BASCULER la disponibilité d'une salle
  Future<void> toggleRoomAvailability(String roomId, bool isAvailable) async {
    try {
      await _firestore.collection(_collection).doc(roomId).update({
        'isAvailable': isAvailable,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Erreur lors de la modification de la disponibilité: $e');
    }
  }

  // 📊 OBTENIR les bâtiments disponibles
  Future<List<String>> getAvailableBuildings() async {
    try {
      final querySnapshot = await _firestore.collection(_collection).get();
      final buildings = <String>{};

      for (var doc in querySnapshot.docs) {
        final building = doc.data()['building'] as String?;
        if (building != null && building.isNotEmpty) {
          buildings.add(building);
        }
      }

      return buildings.toList()..sort();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des bâtiments: $e');
    }
  }

  // 🎛️ OBTENIR les équipements disponibles
  Future<List<String>> getAvailableEquipment() async {
    try {
      final querySnapshot = await _firestore.collection(_collection).get();
      final equipment = <String>{};

      for (var doc in querySnapshot.docs) {
        final equipmentList = doc.data()['equipment'] as List<dynamic>?;
        if (equipmentList != null) {
          for (var item in equipmentList) {
            equipment.add(item.toString());
          }
        }
      }

      return equipment.toList()..sort();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des équipements: $e');
    }
  }

  // Stream en temps réel pour toutes les salles
  Stream<List<RoomModel>> getRoomsStream() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => RoomModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // Stream en temps réel pour une salle spécifique
  Stream<RoomModel?> getRoomStream(String roomId) {
    return _firestore
        .collection(_collection)
        .doc(roomId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return RoomModel.fromFirestore(snapshot.data()!, snapshot.id);
      }
      return null;
    });
  }
}
