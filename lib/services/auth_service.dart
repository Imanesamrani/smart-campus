import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AuthService() {
    // ⚠️ Ce constructeur s'exécute peut-être trop tard
    // Ne pas mettre setSettings ici
  }

  // ✅ NOUVELLE MÉTHODE D'INITIALISATION
  static Future<void> initialize() async {
    try {
      if (kDebugMode) {
        await FirebaseAuth.instance.setSettings(
          appVerificationDisabledForTesting: true,
        );
        print('✅ reCAPTCHA désactivé pour le mode debug');
      }
    } catch (e) {
      print('⚠️ Erreur configuration: $e');
    }
  }

  // Stream d'utilisateur pour écouter les changements d'état
  Stream<UserModel?> get user {
    return _auth.authStateChanges().asyncMap((User? user) async {
      if (user == null) return null;
      return await getUserData(user.uid);
    });
  }

  // Récupérer les données utilisateur depuis Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc.data()!, uid);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Inscription avec email/mot de passe
  Future<String?> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
    String role = 'étudiant',
    String? filiere,
    String? niveau,
  }) async {
    try {
      // ✅ Réappliquer la configuration AVANT chaque inscription
      if (kDebugMode) {
        try {
          await _auth.setSettings(
            appVerificationDisabledForTesting: true,
          );
          print('✅ reCAPTCHA désactivé avant inscription');
        } catch (e) {
          print('⚠️ Erreur config reCAPTCHA: $e');
        }
      }

      // Validation de l'email
      if (!email.contains('@')) {
        return 'Email invalide';
      }

      // Création de l'utilisateur dans Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        // Mise à jour du profil
        await user.updateDisplayName(displayName);
        await user.reload();

        // Création du document utilisateur dans Firestore
        UserModel newUser = UserModel(
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

        // Sauvegarde sécurisée des credentials
        await _secureStorage.write(key: 'email', value: email);
        
        print('✅ Inscription réussie pour $email');
        
        // Déconnexion pour redirection vers login
        await _auth.signOut();
        print('✅ Utilisateur déconnecté - Redirection vers login');
        
        return null;
      }
      return 'Erreur lors de la création du compte';
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.code}');
      
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
          return '⚠️ Problème reCAPTCHA - Vérifiez votre configuration Firebase';
        default:
          return 'Erreur: ${e.message}';
      }
    } catch (e) {
      print('❌ Erreur inattendue: $e');
      return 'Erreur inattendue: $e';
    }
  }

  // Connexion avec email/mot de passe
  Future<String?> signInWithEmail(String email, String password) async {
    try {
      // ✅ Appliquer aussi pour la connexion
      if (kDebugMode) {
        try {
          await _auth.setSettings(
            appVerificationDisabledForTesting: true,
          );
        } catch (e) {}
      }

      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        // Mise à jour de la dernière connexion
        await _firestore.collection('users').doc(user.uid).update({
          'lastLogin': Timestamp.fromDate(DateTime.now()),
        });

        await _secureStorage.write(key: 'email', value: email);
        print('✅ Connexion réussie pour $email');
        return null;
      }
      return 'Erreur de connexion';
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'Aucun utilisateur trouvé avec cet email';
        case 'wrong-password':
          return 'Mot de passe incorrect';
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

  // Déconnexion
  Future<void> signOut() async {
    await _auth.signOut();
    await _secureStorage.delete(key: 'email');
    print('✅ Déconnexion réussie');
  }

  // Réinitialisation du mot de passe
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

  // Mettre à jour le profil utilisateur
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
      print('✅ Profil mis à jour pour $uid');
    } catch (e) {
      print('❌ Erreur mise à jour profil: $e');
      throw Exception('Erreur lors de la mise à jour du profil: $e');
    }
  }

  // Mettre à jour le nom d'affichage
  Future<void> updateDisplayName(String newName) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(newName);
        await user.reload();
        print('✅ Nom d\'affichage mis à jour');
      }
    } catch (e) {
      print('❌ Erreur mise à jour nom: $e');
      throw Exception('Erreur lors de la mise à jour du nom: $e');
    }
  }

}