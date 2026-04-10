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

  List<RoomModel> get rooms => _rooms;
  List<RoomModel> get filteredRooms => _filteredRooms;
  RoomModel? get selectedRoom => _selectedRoom;
  List<String> get availableBuildings => _availableBuildings;
  List<String> get availableEquipment => _availableEquipment;
  bool get isLoading => _isLoading;
  String? get error => _error;

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

  Future<bool> addRoom(RoomModel room) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final createdRoomId = await _roomService.createRoom(room);
      _rooms.add(room.copyWith(id: createdRoomId));
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

  Future<bool> updateRoom(String roomId, RoomModel updatedRoom) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _roomService.updateRoom(roomId, updatedRoom);

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

  void searchRooms(String query) {
    if (query.isEmpty) {
      _filteredRooms = List.from(_rooms);
    } else {
      _filteredRooms = _rooms
          .where(
            (room) =>
                room.name.toLowerCase().contains(query.toLowerCase()) ||
                room.building.toLowerCase().contains(query.toLowerCase()) ||
                room.description.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
    notifyListeners();
  }

  void filterByBuilding(String building) {
    if (building.isEmpty) {
      _filteredRooms = List.from(_rooms);
    } else {
      _filteredRooms =
          _rooms.where((room) => room.building == building).toList();
    }
    notifyListeners();
  }

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

  void filterByMinCapacity(int minCapacity) {
    if (minCapacity <= 0) {
      _filteredRooms = List.from(_rooms);
    } else {
      _filteredRooms =
          _rooms.where((room) => room.capacity >= minCapacity).toList();
    }
    notifyListeners();
  }

  void filterByMaxCapacity(int maxCapacity) {
    if (maxCapacity <= 0) {
      _filteredRooms = List.from(_rooms);
    } else {
      _filteredRooms =
          _rooms.where((room) => room.capacity <= maxCapacity).toList();
    }
    notifyListeners();
  }

  void applyAdvancedFilters({
    String? searchQuery,
    String? building,
    List<String>? equipment,
    int? minCapacity,
    int? maxCapacity,
  }) {
    _filteredRooms = _rooms.where((room) {
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final matchesSearch = room.name.toLowerCase().contains(query) ||
            room.building.toLowerCase().contains(query) ||
            room.description.toLowerCase().contains(query) ||
            room.id.toLowerCase().contains(query);
        if (!matchesSearch) return false;
      }

      if (building != null && building.isNotEmpty) {
        if (room.building != building) return false;
      }

      if (equipment != null && equipment.isNotEmpty) {
        if (!equipment.every((eq) => room.equipment.contains(eq))) return false;
      }

      if (minCapacity != null && minCapacity > 0) {
        if (room.capacity < minCapacity) return false;
      }

      if (maxCapacity != null && maxCapacity > 0) {
        if (room.capacity > maxCapacity) return false;
      }

      return true;
    }).toList();

    notifyListeners();
  }

  void resetFilters() {
    _filteredRooms = List.from(_rooms);
    notifyListeners();
  }

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

  void selectRoom(RoomModel room) {
    _selectedRoom = room;
    notifyListeners();
  }

  Future<void> _loadAvailableOptions() async {
    try {
      _availableBuildings = await _roomService.getAvailableBuildings();
      _availableEquipment = await _roomService.getAvailableEquipment();
    } catch (e) {
      // Non-blocking.
    }
    notifyListeners();
  }

  Future<void> loadAvailableOptions() async {
    await _loadAvailableOptions();
  }

  Stream<List<RoomModel>> getRoomsStream() {
    return _roomService.getRoomsStream();
  }
}
