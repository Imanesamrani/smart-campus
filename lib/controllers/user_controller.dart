import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class UserController extends ChangeNotifier {
  final UserService _userService = UserService();

  final List<UserModel> _users = [];
  List<UserModel> _filteredUsers = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String? _selectedRole;

  // Getters
  List<UserModel> get users => _users;
  List<UserModel> get filteredUsers =>
      _filteredUsers.isEmpty && _searchQuery.isEmpty && _selectedRole == null
          ? _users
          : _filteredUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedRole => _selectedRole;

  /// Charger tous les utilisateurs
  Future<void> loadUsers() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _users.clear();
      _users.addAll(await _userService.getAllUsers());
      _filteredUsers.clear();
      _filteredUsers.addAll(_users);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Flux des utilisateurs en temps réel
  Stream<List<UserModel>> getUsersStream() {
    return _userService.getUsersStream();
  }

  /// Créer un nouvel utilisateur
  Future<bool> createUser({
    required String email,
    required String password,
    required String displayName,
    required String role,
    String? filiere,
    String? niveau,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _userService.createUserAsAdmin(
        email: email,
        password: password,
        displayName: displayName,
        role: role,
        filiere: filiere,
        niveau: niveau,
      );

      await loadUsers();
      return true;
    } catch (e) {
      _error = 'Erreur: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Mettre à jour un utilisateur
  Future<bool> updateUser(
    String uid, {
    String? displayName,
    String? role,
    String? filiere,
    String? niveau,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _userService.updateUser(
        uid,
        displayName: displayName,
        role: role,
        filiere: filiere,
        niveau: niveau,
      );

      await loadUsers();
      return true;
    } catch (e) {
      _error = 'Erreur: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Supprimer un utilisateur
  Future<bool> deleteUser(String uid) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _userService.deleteUser(uid);
      await loadUsers();
      return true;
    } catch (e) {
      _error = 'Erreur: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Rechercher les utilisateurs
  void searchUsers(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  /// Filtrer par rôle
  void filterByRole(String? role) {
    _selectedRole = role;
    _applyFilters();
    notifyListeners();
  }

  /// Appliquer les filtres
  void _applyFilters() {
    _filteredUsers = _users.where((user) {
      bool matchesSearch = _searchQuery.isEmpty ||
          user.displayName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());

      bool matchesRole = _selectedRole == null || user.role == _selectedRole;

      return matchesSearch && matchesRole;
    }).toList();
  }

  /// Réinitialiser les filtres
  void resetFilters() {
    _searchQuery = '';
    _selectedRole = null;
    _filteredUsers.clear();
    _filteredUsers.addAll(_users);
    notifyListeners();
  }

  /// Récupérer les statistiques des utilisateurs
  Future<Map<String, int>> getUserStats() async {
    try {
      return await _userService.getUserCountByRole();
    } catch (e) {
      return {};
    }
  }
}
