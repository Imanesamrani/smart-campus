import 'package:flutter/foundation.dart';
import '../models/room_model.dart';
import '../services/room_service.dart';

class RoomController extends ChangeNotifier {
  final RoomService _roomService = RoomService();

  List<RoomModel> _rooms = [];
  List<RoomModel> _filteredRooms = [];
  RoomModel? _selectedRoom;
  List<String> _availableBuildings = [];
  List<String> _availableEquipment = [];

  bool _isLoading = false;
  String? _error;

  // Getters
  List<RoomModel> get rooms => _rooms;
  List<RoomModel> get filteredRooms => _filteredRooms;
  RoomModel? get selectedRoom => _selectedRoom;
  List<String> get availableBuildings => _availableBuildings;
  List<String> get availableEquipment => _availableEquipment;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 📥 CHARGER toutes les salles
  Future<void> loadRooms() async {
    _isLoading = true;
    _error = null;
    Future.microtask(() => notifyListeners());

    try {
      _rooms = await _roomService.getAllRooms();
      _filteredRooms = List.from(_rooms);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  

  // 📌 AJOUTER une nouvelle salle (Admin)
  Future<bool> addRoom(RoomModel room) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _roomService.createRoom(room);
      _rooms.add(room.copyWith());
      _filteredRooms = List.from(_rooms);
      await _loadAvailableOptions();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✏️ MODIFIER une salle (Admin)
  Future<bool> updateRoom(String roomId, RoomModel updatedRoom) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _roomService.updateRoom(roomId, updatedRoom);

      // Mettre à jour la liste locale
      final index = _rooms.indexWhere((r) => r.id == roomId);
      if (index != -1) {
        _rooms[index] = updatedRoom;
        _filteredRooms = List.from(_rooms);
      }

      if (_selectedRoom?.id == roomId) {
        _selectedRoom = updatedRoom;
      }

      await _loadAvailableOptions();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ❌ SUPPRIMER une salle (Admin)
  Future<bool> deleteRoom(String roomId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _roomService.deleteRoom(roomId);
      _rooms.removeWhere((r) => r.id == roomId);
      _filteredRooms = List.from(_rooms);

      if (_selectedRoom?.id == roomId) {
        _selectedRoom = null;
      }

      await _loadAvailableOptions();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🔍 RECHERCHER des salles
  void searchRooms(String query) {
    if (query.isEmpty) {
      _filteredRooms = List.from(_rooms);
    } else {
      _filteredRooms = _rooms
          .where((room) =>
              room.name.toLowerCase().contains(query.toLowerCase()) ||
              room.building.toLowerCase().contains(query.toLowerCase()) ||
              room.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  // 🏗️ FILTRER par bâtiment
  void filterByBuilding(String building) {
    if (building.isEmpty) {
      _filteredRooms = List.from(_rooms);
    } else {
      _filteredRooms = _rooms.where((room) => room.building == building).toList();
    }
    notifyListeners();
  }

  // 🎛️ FILTRER par équipement
  void filterByEquipment(List<String> selectedEquipment) {
    if (selectedEquipment.isEmpty) {
      _filteredRooms = List.from(_rooms);
    } else {
      _filteredRooms = _rooms.where((room) {
        return selectedEquipment.every((eq) => room.equipment.contains(eq));
      }).toList();
    }
    notifyListeners();
  }

  // 👥 FILTRER par capacité minimum
  void filterByMinCapacity(int minCapacity) {
    if (minCapacity <= 0) {
      _filteredRooms = List.from(_rooms);
    } else {
      _filteredRooms = _rooms.where((room) => room.capacity >= minCapacity).toList();
    }
    notifyListeners();
  }

  // 👥 FILTRER par capacité maximum
  void filterByMaxCapacity(int maxCapacity) {
    if (maxCapacity <= 0) {
      _filteredRooms = List.from(_rooms);
    } else {
      _filteredRooms = _rooms.where((room) => room.capacity <= maxCapacity).toList();
    }
    notifyListeners();
  }

  // 🔀 FILTRER combiné (recherche + bâtiment + équipement + capacité)
  void applyAdvancedFilters({
    String? searchQuery,
    String? building,
    List<String>? equipment,
    int? minCapacity,
    int? maxCapacity,
  }) {
    _filteredRooms = _rooms.where((room) {
      // Filtre par recherche
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final matchesSearch = room.name.toLowerCase().contains(query) ||
            room.building.toLowerCase().contains(query) ||
            room.description.toLowerCase().contains(query) ||
            room.id.toLowerCase().contains(query);
        if (!matchesSearch) return false;
      }

      // Filtre par bâtiment
      if (building != null && building.isNotEmpty) {
        if (room.building != building) return false;
      }

      // Filtre par équipement
      if (equipment != null && equipment.isNotEmpty) {
        if (!equipment.every((eq) => room.equipment.contains(eq))) return false;
      }

      // Filtre par capacité minimum
      if (minCapacity != null && minCapacity > 0) {
        if (room.capacity < minCapacity) return false;
      }

      // Filtre par capacité maximum
      if (maxCapacity != null && maxCapacity > 0) {
        if (room.capacity > maxCapacity) return false;
      }

      return true;
    }).toList();

    notifyListeners();
  }

  // 🔄 RESET tous les filtres
  void resetFilters() {
    _filteredRooms = List.from(_rooms);
    notifyListeners();
  }

  // 🔴 BASCULER la disponibilité
  Future<bool> toggleAvailability(String roomId, bool isAvailable) async {
    try {
      await _roomService.toggleRoomAvailability(roomId, isAvailable);

      final index = _rooms.indexWhere((r) => r.id == roomId);
      if (index != -1) {
        _rooms[index] = _rooms[index].copyWith(isAvailable: isAvailable);
        _filteredRooms = List.from(_rooms);
      }

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }

  // 👁️ SÉLECTIONNER une salle
  void selectRoom(RoomModel room) {
    _selectedRoom = room;
    notifyListeners();
  }

  // 🔄 CHARGER les options disponibles (bâtiments, équipements)
  Future<void> _loadAvailableOptions() async {
    try {
      _availableBuildings = await _roomService.getAvailableBuildings();
      _availableEquipment = await _roomService.getAvailableEquipment();
    } catch (e) {
      // Silencieusement échouer, les options ne sont pas essentielles
    }
    notifyListeners();
  }

  // 📊 CHARGER les options au démarrage
  Future<void> loadAvailableOptions() async {
    await _loadAvailableOptions();
  }

  // 🆎 OBTENIR un stream des salles pour les mises à jour en temps réel
  Stream<List<RoomModel>> getRoomsStream() {
    return _roomService.getRoomsStream();
  }
}
