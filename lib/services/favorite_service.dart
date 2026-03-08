import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/favorite_model.dart';

class FavoriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection path
  String _getUserFavoritesCollection(String userId) {
    return 'users/$userId/favorites';
  }

  // Ajouter une salle aux favoris
  Future<void> addFavorite({
    required String userId,
    required String roomId,
    required String roomName,
    required String building,
    required int capacity,
    required List<String> equipment,
  }) async {
    try {
      final favoritesRef = _firestore.collection(_getUserFavoritesCollection(userId));

      // Vérifie si déjà en favoris
      final existing = await favoritesRef.where('roomId', isEqualTo: roomId).get();
      if (existing.docs.isNotEmpty) {
        return; // Déjà en favoris
      }

      await favoritesRef.add(
        FavoriteModel(
          id: '', // Firestore générera l'ID
          userId: userId,
          roomId: roomId,
          roomName: roomName,
          building: building,
          capacity: capacity,
          equipment: equipment,
          addedAt: DateTime.now(),
        ).toFirestore(),
      );
    } catch (e) {
      print('Erreur lors de l\'ajout aux favoris: $e');
      rethrow;
    }
  }

  // Retirer une salle des favoris
  Future<void> removeFavorite({
    required String userId,
    required String roomId,
  }) async {
    try {
      final favoritesRef = _firestore.collection(_getUserFavoritesCollection(userId));
      final doc = await favoritesRef.where('roomId', isEqualTo: roomId).get();

      for (var favorite in doc.docs) {
        await favorite.reference.delete();
      }
    } catch (e) {
      print('Erreur lors de la suppression des favoris: $e');
      rethrow;
    }
  }

  // Récupérer tous les favoris d'un utilisateur
  Future<List<FavoriteModel>> getUserFavorites(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_getUserFavoritesCollection(userId))
          .orderBy('addedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => FavoriteModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Erreur lors de la récupération des favoris: $e');
      return [];
    }
  }

  // Stream des favoris (mise à jour en temps réel)
  Stream<List<FavoriteModel>> getUserFavoritesStream(String userId) {
    try {
      return _firestore
          .collection(_getUserFavoritesCollection(userId))
          .orderBy('addedAt', descending: true)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => FavoriteModel.fromFirestore(doc)).toList());
    } catch (e) {
      print('Erreur lors de l\'obtention du stream des favoris: $e');
      return Stream.value([]);
    }
  }

  // Vérifier si une salle est en favoris
  Future<bool> isFavorite({
    required String userId,
    required String roomId,
  }) async {
    try {
      final doc = await _firestore
          .collection(_getUserFavoritesCollection(userId))
          .where('roomId', isEqualTo: roomId)
          .get();

      return doc.docs.isNotEmpty;
    } catch (e) {
      print('Erreur lors de la vérification des favoris: $e');
      return false;
    }
  }

  // Récupérer le nombre de favoris
  Future<int> getFavoritesCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_getUserFavoritesCollection(userId))
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      print('Erreur lors du comptage des favoris: $e');
      return 0;
    }
  }
}
