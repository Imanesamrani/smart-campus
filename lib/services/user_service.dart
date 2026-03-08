import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Récupérer tous les utilisateurs
  Future<List<UserModel>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore.collection('users').get();
      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des utilisateurs: $e');
    }
  }

  /// Récupérer les utilisateurs en streaming (en temps réel)
  Stream<List<UserModel>> getUsersStream() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  /// Récupérer un utilisateur par UID
  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc.data()!, uid);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'utilisateur: $e');
    }
  }

  /// Créer un nouvel utilisateur (par admin)
  Future<String> createUserAsAdmin({
    required String email,
    required String password,
    required String displayName,
    required String role,
    String? filiere,
    String? niveau,
  }) async {
    try {
      // Créer l'utilisateur dans Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;
      if (user == null) throw Exception('Impossible de créer l\'utilisateur');

      // Mettre à jour le profil
      await user.updateDisplayName(displayName);
      await user.reload();

      // Créer le document dans Firestore
      final newUser = UserModel(
        uid: user.uid,
        email: email,
        displayName: displayName,
        photoURL: null,
        role: role,
        filiere: filiere,
        niveau: niveau,
        favoriteRooms: [],
        favoriteBuildings: [],
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        notificationToken: null,
      );

      await _firestore.collection('users').doc(user.uid).set(newUser.toFirestore());
      return user.uid;
    } catch (e) {
      throw Exception('Erreur lors de la création de l\'utilisateur: $e');
    }
  }

  /// Mettre à jour un utilisateur
  Future<void> updateUser(
    String uid, {
    String? displayName,
    String? role,
    String? filiere,
    String? niveau,
  }) async {
    try {
      Map<String, dynamic> updateData = {};

      if (displayName != null) updateData['displayName'] = displayName;
      if (role != null) updateData['role'] = role;
      if (filiere != null) updateData['filiere'] = filiere;
      if (niveau != null) updateData['niveau'] = niveau;

      if (updateData.isEmpty) return;

      await _firestore.collection('users').doc(uid).update(updateData);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de l\'utilisateur: $e');
    }
  }

  /// Supprimer un utilisateur
  Future<void> deleteUser(String uid) async {
    try {
      // Supprimer les favoris de l'utilisateur
      final favoritesSnapshot =
          await _firestore.collection('users').doc(uid).collection('favorites').get();
      for (final doc in favoritesSnapshot.docs) {
        await doc.reference.delete();
      }

      // Supprimer le document utilisateur
      await _firestore.collection('users').doc(uid).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'utilisateur: $e');
    }
  }

  /// Récupérer les utilisateurs filtrés par rôle
  Future<List<UserModel>> getUsersByRole(String role) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: role)
          .get();
      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des utilisateurs: $e');
    }
  }

  /// Compter les utilisateurs par rôle
  Future<Map<String, int>> getUserCountByRole() async {
    try {
      final users = await getAllUsers();
      final counts = <String, int>{};

      for (final user in users) {
        counts[user.role] = (counts[user.role] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      throw Exception('Erreur lors du comptage des utilisateurs: $e');
    }
  }
}
