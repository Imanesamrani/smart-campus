import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  // Stream pour écouter les changements d'utilisateur
  Stream<UserModel?> get user => _authService.user;

  AuthController() {
    _authService.user.listen((UserModel? user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  // Inscription
  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
    String role = 'étudiant',
    String? filiere,
    String? niveau,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final error = await _authService.registerWithEmail(
        email: email.trim(),
        password: password.trim(),
        displayName: displayName.trim(),
        role: role,
        filiere: filiere,
        niveau: niveau,
      );

      if (error != null) {
        _errorMessage = error;
        _setLoading(false);
        return false;
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'inscription';
      _setLoading(false);
      return false;
    }
  }

  // Connexion
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final error = await _authService.signInWithEmail(
        email.trim(), 
        password.trim()
      );

      if (error != null) {
        _errorMessage = error;
        _setLoading(false);
        return false;
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la connexion';
      _setLoading(false);
      return false;
    }
  }

  // Déconnexion
  Future<void> logout() async {
    _setLoading(true);
    await _authService.signOut();
    _currentUser = null;
    _setLoading(false);
  }

  // Réinitialisation du mot de passe
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      final error = await _authService.resetPassword(email.trim());

      if (error != null) {
        _errorMessage = error;
        _setLoading(false);
        return false;
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la réinitialisation';
      _setLoading(false);
      return false;
    }
  }

  // Vérifier si l'utilisateur a un rôle spécifique
  bool hasRole(String role) {
    return _currentUser?.role == role;
  }

  bool get isStudent => hasRole('étudiant');
  bool get isTeacher => hasRole('enseignant');
  bool get isAdmin => hasRole('admin');

  // Méthodes privées
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}