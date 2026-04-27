import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/building.dart';

class BuildingController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Building> _buildings = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  List<Building> get buildings => _buildings;
  List<String> get buildingNames => _buildings.map((b) => b.name).toList();
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;

  // Charger tous les bâtiments
  Future<void> loadBuildings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection('buildings').get();
      _buildings = snapshot.docs
          .map((doc) => Building.fromMap(doc.data(), doc.id))
          .toList();

      // Trier par nom
      _buildings.sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      _error = e.toString();
      debugPrint('Erreur chargement bâtiments: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Rafraîchir la liste
  Future<void> refreshBuildings() async {
    await loadBuildings();
  }

  Future<bool> addBuilding(Building building) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final normalizedName = building.name.trim().toLowerCase();
      final exists = _buildings.any(
        (item) => item.name.trim().toLowerCase() == normalizedName,
      );

      if (exists) {
        _error = 'Un bâtiment avec ce nom existe déjà.';
        return false;
      }

      final doc = _firestore.collection('buildings').doc();
      final buildingToSave = Building(
        id: doc.id,
        name: building.name.trim(),
        code: building.code.trim(),
        address: building.address.trim(),
        latitude: building.latitude,
        longitude: building.longitude,
        floors: building.floors,
        description: building.description.trim(),
        imageUrl: building.imageUrl.trim(),
        openingHours: building.openingHours,
        services: building.services,
      );

      await doc.set(buildingToSave.toMap());
      _buildings.add(buildingToSave);
      _buildings.sort((a, b) => a.name.compareTo(b.name));
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Erreur ajout bâtiment: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // Obtenir un bâtiment par son nom
  Building? getBuildingByName(String name) {
    try {
      return _buildings.firstWhere((b) => b.name == name);
    } catch (_) {
      return null;
    }
  }
}

