import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AuthService();

  static Future<void> initialize() async {
    try {
      if (kDebugMode) {
        await FirebaseAuth.instance.setSettings(
          appVerificationDisabledForTesting: true,
        );
        debugPrint('reCAPTCHA disabled for debug mode');
      }
    } catch (e) {
      debugPrint('Firebase auth configuration error: $e');
    }
  }

  Stream<UserModel?> get user {
    return _auth.authStateChanges().asyncMap((User? user) async {
      if (user == null) return null;
      return getUserData(user.uid);
    });
  }

  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc.data()!, uid);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<String?> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
    String role = 'étudiant',
    String? filiere,
    String? niveau,
  }) async {
    try {
      if (kDebugMode) {
        try {
          await _auth.setSettings(
            appVerificationDisabledForTesting: true,
          );
        } catch (e) {
          debugPrint('reCAPTCHA setup failed before sign-up: $e');
        }
      }

      if (!email.contains('@')) {
        return 'Email invalide';
      }

      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;
      if (user == null) {
        return 'Erreur lors de la création du compte';
      }

      await user.updateDisplayName(displayName);
      await user.reload();

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
      );

      await _firestore.collection('users').doc(user.uid).set(
            newUser.toFirestore(),
          );

      await _secureStorage.write(key: 'email', value: email);
      await _auth.signOut();
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'Cet email est déjà utilisé';
        case 'invalid-email':
          return 'Email invalide';
        case 'weak-password':
          return 'Mot de passe trop faible (minimum 6 caractères)';
        case 'operation-not-allowed':
          return 'L\'inscription par email/mot de passe n\'est pas activée';
        case 'configuration-not-found':
          return 'Problème reCAPTCHA - vérifiez la configuration Firebase';
        default:
          return 'Erreur: ${e.message}';
      }
    } catch (e) {
      debugPrint('Unexpected sign-up error: $e');
      return 'Erreur inattendue: $e';
    }
  }

  Future<String?> signInWithEmail(String email, String password) async {
    try {
      if (kDebugMode) {
        try {
          await _auth.setSettings(
            appVerificationDisabledForTesting: true,
          );
        } catch (e) {
          debugPrint('reCAPTCHA setup failed before sign-in: $e');
        }
      }

      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;
      if (user == null) {
        return 'Erreur de connexion';
      }

      final userData = await getUserData(user.uid);
      if (userData == null) {
        await _auth.signOut();
        return 'Ce compte a été supprimé ou désactivé';
      }

      await _firestore.collection('users').doc(user.uid).update({
        'lastLogin': Timestamp.fromDate(DateTime.now()),
      });

      await _secureStorage.write(key: 'email', value: email);
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'Aucun utilisateur trouvé avec cet email';
        case 'wrong-password':
          return 'Mot de passe incorrect';
        case 'invalid-credential':
          return 'Email ou mot de passe incorrect';
        case 'invalid-email':
          return 'Email invalide';
        case 'user-disabled':
          return 'Ce compte a été désactivé';
        default:
          return 'Erreur: ${e.message}';
      }
    } catch (e) {
      return 'Erreur inattendue: $e';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _secureStorage.delete(key: 'email');
  }

  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'Aucun utilisateur trouvé avec cet email';
        case 'invalid-email':
          return 'Email invalide';
        default:
          return 'Erreur: ${e.message}';
      }
    } catch (e) {
      return 'Erreur inattendue: $e';
    }
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du profil: $e');
    }
  }

  Future<void> updateDisplayName(String newName) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(newName);
        await user.reload();
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du nom: $e');
    }
  }
}
