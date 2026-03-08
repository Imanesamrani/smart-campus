import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/room_controller.dart';
import '../controllers/favorite_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/room_model.dart';
import 'room_details_screen.dart';

class RoomsListScreen extends StatefulWidget {
  const RoomsListScreen({super.key});

  @override
  State<RoomsListScreen> createState() => _RoomsListScreenState();
}

class _RoomsListScreenState extends State<RoomsListScreen> {
  late RoomController _roomController;
  final TextEditingController _searchController = TextEditingController();
  String? _selectedBuilding;
  List<String> _selectedEquipment = [];
  int? _minCapacity;
  int? _maxCapacity;

  @override
  void initState() {
    super.initState();
    _roomController = context.read<RoomController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await _roomController.loadRooms();
    await _roomController.loadAvailableOptions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    _roomController.applyAdvancedFilters(
      searchQuery: _searchController.text,
      building: _selectedBuilding,
      equipment: _selectedEquipment.isNotEmpty ? _selectedEquipment : null,
      minCapacity: _minCapacity,
      maxCapacity: _maxCapacity,
    );
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedBuilding = null;
      _selectedEquipment.clear();
      _minCapacity = null;
      _maxCapacity = null;
    });
    _roomController.resetFilters();
  }

  void _openAdvancedFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              top: 24,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filtres avancés',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 16),

                // 🏢 Filtrer par bâtiment
                const Text(
                  '🏢 Bâtiment',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('Tous'),
                        selected: _selectedBuilding == null,
                        onSelected: (selected) {
                          setState(() => _selectedBuilding = null);
                        },
                      ),
                      const SizedBox(width: 8),
                      ..._roomController.availableBuildings
                          .map((building) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(building),
                                  selected: _selectedBuilding == building,
                                  onSelected: (selected) {
                                    setState(
                                        () => _selectedBuilding = building);
                                  },
                                ),
                              ))
                          .toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 👥 Filtrer par capacité
                const Text(
                  '👥 Capacité d\'accueil',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Minimum', style: TextStyle(fontSize: 12)),
                          const SizedBox(height: 8),
                          TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Ex: 10',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _minCapacity =
                                    int.tryParse(value);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Maximum', style: TextStyle(fontSize: 12)),
                          const SizedBox(height: 8),
                          TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Ex: 50',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _maxCapacity =
                                    int.tryParse(value);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 🎛️ Filtrer par équipements
                const Text(
                  '🎛️ Équipements',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _roomController.availableEquipment
                      .map((equipment) => FilterChip(
                            label: Text(equipment),
                            selected: _selectedEquipment.contains(equipment),
                            onSelected: (selected) {
                              setState(() {
                                if (_selectedEquipment.contains(equipment)) {
                                  _selectedEquipment.remove(equipment);
                                } else {
                                  _selectedEquipment.add(equipment);
                                }
                              });
                            },
                          ))
                      .toList(),
                ),
                const SizedBox(height: 24),

                // Boutons d'action
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          this._resetFilters();
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Réinitialiser'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _applyFilters();
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Appliquer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salles du Campus'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Column(
        children: [
          // 🔍 Barre de recherche améliorée
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                // Champ de recherche
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (query) {
                          _applyFilters();
                        },
                        decoration: InputDecoration(
                          hintText: 'Rechercher par nom, numéro ou bâtiment...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    _applyFilters();
                                  },
                                  icon: const Icon(Icons.clear),
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Bouton filtres
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: _openAdvancedFilterBottomSheet,
                        icon: const Icon(Icons.tune),
                        color: Colors.white,
                        tooltip: 'Filtres avancés',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Filtre pills (tags)
                if (_selectedBuilding != null ||
                    _selectedEquipment.isNotEmpty ||
                    _minCapacity != null ||
                    _maxCapacity != null)
                  Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (_selectedBuilding != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Chip(
                                  label: Text('🏢 $_selectedBuilding'),
                                  onDeleted: () {
                                    setState(() => _selectedBuilding = null);
                                    _applyFilters();
                                  },
                                  backgroundColor: Colors.blue.shade100,
                                ),
                              ),
                            if (_minCapacity != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Chip(
                                  label: Text('👥 Min: $_minCapacity'),
                                  onDeleted: () {
                                    setState(() => _minCapacity = null);
                                    _applyFilters();
                                  },
                                  backgroundColor: Colors.blue.shade100,
                                ),
                              ),
                            if (_maxCapacity != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Chip(
                                  label: Text('👥 Max: $_maxCapacity'),
                                  onDeleted: () {
                                    setState(() => _maxCapacity = null);
                                    _applyFilters();
                                  },
                                  backgroundColor: Colors.blue.shade100,
                                ),
                              ),
                            ..._selectedEquipment.map((eq) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Chip(
                                  label: Text('🎛️ $eq'),
                                  onDeleted: () {
                                    setState(
                                        () => _selectedEquipment.remove(eq));
                                    _applyFilters();
                                  },
                                  backgroundColor: Colors.blue.shade100,
                                ),
                              );
                            }),
                            if (_selectedBuilding != null ||
                                _selectedEquipment.isNotEmpty ||
                                _minCapacity != null ||
                                _maxCapacity != null)
                              GestureDetector(
                                onTap: _resetFilters,
                                child: Chip(
                                  label: const Text('🔄 Réinitialiser'),
                                  backgroundColor: Colors.red.shade100,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
              ],
            ),
          ),

          // 📊 Statistiques des résultats
          Consumer<RoomController>(
            builder: (context, roomController, _) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${roomController.filteredRooms.length} salle${roomController.filteredRooms.length != 1 ? 's' : ''} trouvée${roomController.filteredRooms.length != 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    if (roomController.filteredRooms.isNotEmpty)
                      Text(
                        'Total: ${roomController.filteredRooms.fold<int>(0, (sum, room) => sum + room.capacity)} places',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),

          // 📋 Liste des salles
          Expanded(
            child: Consumer<RoomController>(
              builder: (context, roomController, child) {
                if (roomController.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (roomController.filteredRooms.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        const Text(
                          'Aucune salle trouvée',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Essayez de modifier vos critères de recherche',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: roomController.filteredRooms.length,
                  itemBuilder: (context, index) {
                    final room = roomController.filteredRooms[index];
                    return _RoomListItem(
                      room: room,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RoomDetailsScreen(room: room),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// 🎨 Élément de la liste des salles
class _RoomListItem extends StatefulWidget {
  final RoomModel room;
  final VoidCallback onTap;

  const _RoomListItem({
    required this.room,
    required this.onTap,
  });

  @override
  State<_RoomListItem> createState() => _RoomListItemState();
}

class _RoomListItemState extends State<_RoomListItem> {
  late bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    final favoriteController = context.read<FavoriteController>();
    final isFav = await favoriteController.isFavorite(widget.room.id);
    setState(() {
      _isFavorite = isFav;
    });
  }

  Future<void> _toggleFavorite() async {
    final favoriteController = context.read<FavoriteController>();
    final authController = context.read<AuthController>();

    if (authController.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez vous connecter pour ajouter des favoris')),
      );
      return;
    }

    if (_isFavorite) {
      await favoriteController.removeFavorite(widget.room.id);
      setState(() => _isFavorite = false);
    } else {
      await favoriteController.addFavorite(
        roomId: widget.room.id,
        roomName: widget.room.name,
        building: widget.room.building,
        capacity: widget.room.capacity,
        equipment: widget.room.equipment,
      );
      setState(() => _isFavorite = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🏛️ Icône
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.meeting_room,
                  color: Colors.blue.shade600,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // 📝 Informations
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.room.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.room.building} - Étage ${widget.room.floor}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.people,
                            size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          'Capacité: ${widget.room.capacity}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ❤️ Bouton favoris
              IconButton(
                onPressed: _toggleFavorite,
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.grey,
                ),
              ),

              // ✅ Statut de disponibilité
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: widget.room.isAvailable
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.room.isAvailable ? 'Libre' : 'Occupée',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: widget.room.isAvailable
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
