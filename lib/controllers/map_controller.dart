import 'package:flutter/material.dart';
import '../models/building.dart';
import '../services/building_service.dart';

class CampusMapController extends ChangeNotifier {
  final BuildingService _buildingService = BuildingService();

  List<Building> buildings = [];
  Building? selectedBuilding;
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadBuildings({String? targetBuildingName}) async {
    try {
      isLoading = true;
      errorMessage = null;
      selectedBuilding = null;
      notifyListeners();

      buildings = await _buildingService.getAllBuildings();

      if (targetBuildingName != null && targetBuildingName.trim().isNotEmpty) {
        final target = targetBuildingName.trim().toLowerCase();

        try {
          selectedBuilding = buildings.firstWhere(
            (b) => b.name.trim().toLowerCase() == target,
          );
        } catch (_) {
          selectedBuilding = null;
        }
      }
    } catch (e) {
      errorMessage = 'Erreur lors du chargement des bâtiments : $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}