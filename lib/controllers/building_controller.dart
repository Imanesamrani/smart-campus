import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/building.dart';

class BuildingController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Building> _buildings = [];
  bool _isLoading = false;
  String? _error;

  List<Building> get buildings => _buildings;
  List<String> get buildingNames => _buildings.map((b) => b.name).toList();
  bool get isLoading => _isLoading;
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

  // Obtenir un bâtiment par son nom
  Building? getBuildingByName(String name) {
    try {
      return _buildings.firstWhere((b) => b.name == name);
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}