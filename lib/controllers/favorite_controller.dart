import 'package:flutter/material.dart';
import '../models/favorite_model.dart';
import '../services/favorite_service.dart';

class FavoriteController extends ChangeNotifier {
  final FavoriteService _favoriteService = FavoriteService();

  List<FavoriteModel> _favorites = [];
  bool _isLoading = false;
  String? _error;
  String? _currentUserId;

  // Getters
  List<FavoriteModel> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialiser le contrôleur avec l'ID de l'utilisateur
  void setUserId(String userId) {
    _currentUserId = userId;
  }

  // Charger les favoris de l'utilisateur
  Future<void> loadFavorites() async {
    if (_currentUserId == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _favorites = await _favoriteService.getUserFavorites(_currentUserId!);
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement des favoris';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtenir le stream des favoris
  Stream<List<FavoriteModel>> getFavoritesStream() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }
    return _favoriteService.getUserFavoritesStream(_currentUserId!);
  }

  // Ajouter une salle aux favoris
  Future<void> addFavorite({
    required String roomId,
    required String roomName,
    required String building,
    required int capacity,
    required List<String> equipment,
  }) async {
    if (_currentUserId == null) return;

    try {
      await _favoriteService.addFavorite(
        userId: _currentUserId!,
        roomId: roomId,
        roomName: roomName,
        building: building,
        capacity: capacity,
        equipment: equipment,
      );

      await loadFavorites();
    } catch (e) {
      _error = 'Erreur lors de l\'ajout aux favoris';
      notifyListeners();
    }
  }

  // Retirer une salle des favoris
  Future<void> removeFavorite(String roomId) async {
    if (_currentUserId == null) return;

    try {
      await _favoriteService.removeFavorite(
        userId: _currentUserId!,
        roomId: roomId,
      );

      _favorites.removeWhere((fav) => fav.roomId == roomId);
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de la suppression des favoris';
      notifyListeners();
    }
  }

  // Vérifier si une salle est en favoris
  Future<bool> isFavorite(String roomId) async {
    if (_currentUserId == null) return false;

    return await _favoriteService.isFavorite(
      userId: _currentUserId!,
      roomId: roomId,
    );
  }

  // Obtenir le nombre de favoris
  Future<int> getFavoritesCount() async {
    if (_currentUserId == null) return 0;
    return await _favoriteService.getFavoritesCount(_currentUserId!);
  }

  // Rechercher dans les favoris
  List<FavoriteModel> searchFavorites(String query) {
    if (query.isEmpty) {
      return _favorites;
    }

    final lowerQuery = query.toLowerCase();
    return _favorites
        .where((fav) =>
            fav.roomName.toLowerCase().contains(lowerQuery) ||
            fav.building.toLowerCase().contains(lowerQuery) ||
            fav.equipment.any((eq) => eq.toLowerCase().contains(lowerQuery)))
        .toList();
  }

  // Filtrer par bâtiment
  List<FavoriteModel> filterByBuilding(String building) {
    if (building.isEmpty) {
      return _favorites;
    }
    return _favorites.where((fav) => fav.building == building).toList();
  }

  // Obtenir les bâtiments correspondant aux favoris
  List<String> getAvailableBuildings() {
    final buildings = <String>{};
    for (final fav in _favorites) {
      buildings.add(fav.building);
    }
    return buildings.toList()..sort();
  }

  // Obtenir l'équipement disponible dans les favoris
  List<String> getAvailableEquipment() {
    final equipment = <String>{};
    for (final fav in _favorites) {
      equipment.addAll(fav.equipment);
    }
    return equipment.toList()..sort();
  }
}
