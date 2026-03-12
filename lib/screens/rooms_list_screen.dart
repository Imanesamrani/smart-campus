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
      backgroundColor: Colors.white,
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
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Color(0xFF1E293B)),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),

                // 🏢 Filtrer par bâtiment
                const Text(
                  '🏢 Bâtiment',
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 16,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: 'Tous',
                        selected: _selectedBuilding == null,
                        onSelected: (selected) {
                          setState(() => _selectedBuilding = null);
                        },
                      ),
                      const SizedBox(width: 8),
                      ..._roomController.availableBuildings
                          .map((building) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _buildFilterChip(
                                  label: building,
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 16,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Minimum', 
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Ex: 10',
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF5F7FA),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _minCapacity = int.tryParse(value);
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
                          const Text(
                            'Maximum', 
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Ex: 50',
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF5F7FA),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _maxCapacity = int.tryParse(value);
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 16,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _roomController.availableEquipment
                      .map((equipment) => _buildFilterChip(
                            label: equipment,
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
                const SizedBox(height: 32),

                // Boutons d'action
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          this._resetFilters();
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFF1E88E5)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Réinitialiser',
                          style: TextStyle(color: Color(0xFF1E88E5)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _applyFilters();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E88E5),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('Appliquer'),
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

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: const Color(0xFFF5F7FA),
      selectedColor: const Color(0xFF1E88E5).withOpacity(0.1),
      checkmarkColor: const Color(0xFF1E88E5),
      labelStyle: TextStyle(
        color: selected ? const Color(0xFF1E88E5) : const Color(0xFF1E293B),
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: BorderSide(
          color: selected 
              ? const Color(0xFF1E88E5) 
              : Colors.grey.withOpacity(0.3),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Salles du Campus',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: Column(
        children: [
          // 🔍 Barre de recherche améliorée
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            color: Colors.white,
            child: Column(
              children: [
                // Champ de recherche
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F7FA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (query) {
                            _applyFilters();
                          },
                          decoration: InputDecoration(
                            hintText: 'Rechercher par nom, numéro ou bâtiment...',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            prefixIcon: const Icon(Icons.search, color: Color(0xFF1E293B)),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      _applyFilters();
                                    },
                                    icon: const Icon(Icons.clear, color: Color(0xFF1E293B)),
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Bouton filtres
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF1E88E5),
                            Color(0xFF1565C0),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1E88E5).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
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
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (_selectedBuilding != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildFilterTag(
                              label: '🏢 $_selectedBuilding',
                              onDeleted: () {
                                setState(() => _selectedBuilding = null);
                                _applyFilters();
                              },
                            ),
                          ),
                        if (_minCapacity != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildFilterTag(
                              label: '👥 Min: $_minCapacity',
                              onDeleted: () {
                                setState(() => _minCapacity = null);
                                _applyFilters();
                              },
                            ),
                          ),
                        if (_maxCapacity != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildFilterTag(
                              label: '👥 Max: $_maxCapacity',
                              onDeleted: () {
                                setState(() => _maxCapacity = null);
                                _applyFilters();
                              },
                            ),
                          ),
                        ..._selectedEquipment.map((eq) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildFilterTag(
                              label: '🎛️ $eq',
                              onDeleted: () {
                                setState(() => _selectedEquipment.remove(eq));
                                _applyFilters();
                              },
                            ),
                          );
                        }),
                        if (_selectedBuilding != null ||
                            _selectedEquipment.isNotEmpty ||
                            _minCapacity != null ||
                            _maxCapacity != null)
                          GestureDetector(
                            onTap: _resetFilters,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.red.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.refresh,
                                    size: 14,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Réinitialiser',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.red.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // 📊 Statistiques des résultats
          Consumer<RoomController>(
            builder: (context, roomController, _) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${roomController.filteredRooms.length} salle${roomController.filteredRooms.length != 1 ? 's' : ''} trouvée${roomController.filteredRooms.length != 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
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
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E88E5)),
                    ),
                  );
                }

                if (roomController.filteredRooms.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.search_off,
                              size: 48, color: Colors.grey.shade400),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Aucune salle trouvée',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
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
                  padding: const EdgeInsets.all(20),
                  itemCount: roomController.filteredRooms.length,
                  itemBuilder: (context, index) {
                    final room = roomController.filteredRooms[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _RoomListItem(
                        room: room,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RoomDetailsScreen(room: room),
                            ),
                          );
                        },
                      ),
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

  Widget _buildFilterTag({
    required String label,
    required VoidCallback onDeleted,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E88E5).withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFF1E88E5).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF1E88E5),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onDeleted,
            child: const Icon(
              Icons.close,
              size: 14,
              color: Color(0xFF1E88E5),
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
    if (mounted) {
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final favoriteController = context.read<FavoriteController>();
    final authController = context.read<AuthController>();

    if (authController.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez vous connecter pour ajouter des favoris'),
          backgroundColor: Color(0xFF1E88E5),
        ),
      );
      return;
    }

    setState(() {
      _isFavorite = !_isFavorite;
    });

    if (_isFavorite) {
      await favoriteController.addFavorite(
        roomId: widget.room.id,
        roomName: widget.room.name,
        building: widget.room.building,
        capacity: widget.room.capacity,
        equipment: widget.room.equipment,
      );
    } else {
      await favoriteController.removeFavorite(widget.room.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
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
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1E88E5),
                      Color(0xFF1565C0),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.meeting_room,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // 📝 Informations
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.room.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // ✅ Statut de disponibilité
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: widget.room.isAvailable
                                ? const Color(0xFF43A047).withOpacity(0.1)
                                : const Color(0xFFE53935).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.room.isAvailable ? 'Libre' : 'Occupée',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: widget.room.isAvailable
                                  ? const Color(0xFF43A047)
                                  : const Color(0xFFE53935),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.room.building} • Étage ${widget.room.floor}',
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
                            size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          'Capacité: ${widget.room.capacity} personnes',
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
              Container(
                decoration: BoxDecoration(
                  color: _isFavorite 
                      ? Colors.red.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: _toggleFavorite,
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.grey,
                    size: 20,
                  ),
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}