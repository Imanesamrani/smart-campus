import 'package:flutter/material.dart';
import '../models/building.dart';
import '../services/building_service.dart';

class CampusMapController extends ChangeNotifier {
  final BuildingService _buildingService = BuildingService();

  List<Building> buildings = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadBuildings() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      buildings = await _buildingService.getAllBuildings();
    } catch (e) {
      errorMessage = 'Erreur lors du chargement des bâtiments : $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}