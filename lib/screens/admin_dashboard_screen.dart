import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../controllers/room_controller.dart';
import '../controllers/user_controller.dart';
import '../models/room_model.dart';
import 'room_form_dialog.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with TickerProviderStateMixin {
  late RoomController _roomController;
  late UserController _userController;
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String? _selectedBuilding;
  List<String> _selectedEquipment = [];

  @override
  void initState() {
    super.initState();
    _roomController = context.read<RoomController>();
    _userController = context.read<UserController>();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await _roomController.loadRooms();
    await _roomController.loadAvailableOptions();
    await _userController.loadUsers();
  }

  List<RoomModel> _filterRooms(List<RoomModel> rooms) {
    return rooms.where((room) {
      // Filtre par recherche
      final matchesSearch = _searchController.text.isEmpty ||
          room.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          room.building.toLowerCase().contains(_searchController.text.toLowerCase());
      
      // Filtre par bâtiment
      final matchesBuilding = _selectedBuilding == null || room.building == _selectedBuilding;
      
      // Filtre par équipements
      final matchesEquipment = _selectedEquipment.isEmpty ||
          _selectedEquipment.every((eq) => room.equipment.contains(eq));
      
      return matchesSearch && matchesBuilding && matchesEquipment;
    }).toList();
  }

  void _openAddRoomDialog() {
    showDialog(
      context: context,
      builder: (context) => RoomFormDialog(
        onSave: (room) async {
          final success = await _roomController.addRoom(room);
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Salle ajoutée avec succès'),
                backgroundColor: Color(0xFF43A047),
              ),
            );
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ Erreur: ${_roomController.error}'),
                backgroundColor: const Color(0xFFE53935),
              ),
            );
          }
        },
      ),
    );
  }

  void _openEditRoomDialog(RoomModel room) {
    showDialog(
      context: context,
      builder: (context) => RoomFormDialog(
        initialRoom: room,
        onSave: (updatedRoom) async {
          final success = await _roomController.updateRoom(room.id, updatedRoom);
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Salle modifiée avec succès'),
                backgroundColor: Color(0xFF43A047),
              ),
            );
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ Erreur: ${_roomController.error}'),
                backgroundColor: const Color(0xFFE53935),
              ),
            );
          }
        },
      ),
    );
  }

  void _deleteRoom(String roomId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Confirmation',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer cette salle ?',
          style: TextStyle(color: Color(0xFF1E293B)),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF1E88E5),
            ),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await _roomController.deleteRoom(roomId);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Salle supprimée avec succès'),
                    backgroundColor: Color(0xFF43A047),
                  ),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Erreur: ${_roomController.error}'),
                    backgroundColor: const Color(0xFFE53935),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final user = authController.currentUser;

    // Vérification du rôle d'administrateur
    if (user?.role != 'admin') {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: const Text(
            'Admin Dashboard',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock,
                    size: 48,
                    color: Color(0xFFE53935),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Accès refusé',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Vous n\'avez pas les permissions d\'administrateur',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF1E88E5),
          labelColor: const Color(0xFF1E88E5),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.meeting_room), text: 'Salles'),
            Tab(icon: Icon(Icons.analytics), text: 'Statistiques'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Onglet Gestion des salles
          _buildRoomsTab(),
          // Onglet Statistiques
          _buildStatsTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: _openAddRoomDialog,
              backgroundColor: const Color(0xFF1E88E5),
              child: const Icon(Icons.add, color: Colors.white),
              elevation: 4,
            )
          : null,
    );
  }

  Widget _buildRoomsTab() {
    return Consumer<RoomController>(
      builder: (context, roomController, child) {
        if (roomController.isLoading && roomController.rooms.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E88E5)),
            ),
          );
        }

        final filteredRooms = _filterRooms(roomController.rooms);

        if (roomController.rooms.isEmpty && !roomController.isLoading) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.meeting_room_outlined,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune salle disponible',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _openAddRoomDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter une salle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            // 🔍 Barre de recherche et filtres
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Champ de recherche
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Rechercher par nom ou bâtiment...',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF1E293B)),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
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
                  
                  // Filtres rapides
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                          label: 'Tous',
                          selected: _selectedBuilding == null,
                          onSelected: (_) {
                            setState(() {
                              _selectedBuilding = null;
                            });
                          },
                        ),
                        ...roomController.availableBuildings.map((building) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: _buildFilterChip(
                              label: building,
                              selected: _selectedBuilding == building,
                              onSelected: (_) {
                                setState(() {
                                  _selectedBuilding = building;
                                });
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  
                  // 📊 Statistiques
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${filteredRooms.length} salle${filteredRooms.length != 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        'Capacité totale: ${filteredRooms.fold<int>(0, (sum, room) => sum + room.capacity)} places',
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

            // 📋 Liste des salles
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: filteredRooms.length,
                itemBuilder: (context, index) {
                  final room = filteredRooms[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _RoomCard(
                      room: room,
                      onEdit: () => _openEditRoomDialog(room),
                      onDelete: () => _deleteRoom(room.id),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsTab() {
    return Consumer2<RoomController, UserController>(
      builder: (context, roomController, userController, child) {
        final totalRooms = roomController.rooms.length;
        final totalCapacity = roomController.rooms.fold<int>(0, (sum, room) => sum + room.capacity);
        final avgCapacity = totalRooms > 0 ? (totalCapacity / totalRooms).round() : 0;
        
        final totalUsers = userController.users.length;
        final students = userController.users.where((u) => u.role == 'étudiant').length;
        final teachers = userController.users.where((u) => u.role == 'enseignant').length;
        final admins = userController.users.where((u) => u.role == 'admin').length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistiques des salles
              const Text(
                '📊 Statistiques des salles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  _buildStatCard(
                    icon: Icons.meeting_room,
                    label: 'Total salles',
                    value: totalRooms.toString(),
                    color: const Color(0xFF1E88E5),
                  ),
                  _buildStatCard(
                    icon: Icons.people,
                    label: 'Capacité totale',
                    value: totalCapacity.toString(),
                    color: const Color(0xFF43A047),
                  ),
                  _buildStatCard(
                    icon: Icons.trending_up,
                    label: 'Capacité moyenne',
                    value: avgCapacity.toString(),
                    color: const Color(0xFFFF9800),
                  ),
                  _buildStatCard(
                    icon: Icons.location_city,
                    label: 'Bâtiments',
                    value: roomController.availableBuildings.length.toString(),
                    color: const Color(0xFF5E35B1),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Statistiques des utilisateurs
              const Text(
                '👥 Statistiques des utilisateurs',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  _buildStatCard(
                    icon: Icons.people,
                    label: 'Total utilisateurs',
                    value: totalUsers.toString(),
                    color: const Color(0xFF1E88E5),
                  ),
                  _buildStatCard(
                    icon: Icons.school,
                    label: 'Étudiants',
                    value: students.toString(),
                    color: const Color(0xFF43A047),
                  ),
                  _buildStatCard(
                    icon: Icons.person,
                    label: 'Enseignants',
                    value: teachers.toString(),
                    color: const Color(0xFFFF9800),
                  ),
                  _buildStatCard(
                    icon: Icons.admin_panel_settings,
                    label: 'Administrateurs',
                    value: admins.toString(),
                    color: const Color(0xFFE53935),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Graphique simple (simulé)
              Container(
                padding: const EdgeInsets.all(16),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Répartition par bâtiment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...roomController.availableBuildings.map((building) {
                      final count = roomController.rooms
                          .where((room) => room.building == building)
                          .length;
                      final percentage = totalRooms > 0 
                          ? (count / totalRooms * 100).round() 
                          : 0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  building,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '$count salles ($percentage%)',
                                  style: const TextStyle(
                                    color: Color(0xFF1E88E5),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: count / totalRooms,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF1E88E5),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// 🎨 Carte de salle pour le dashboard
class _RoomCard extends StatelessWidget {
  final RoomModel room;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RoomCard({
    required this.room,
    required this.onEdit,
    required this.onDelete,
  });

  IconData _getEquipmentIcon(String equipment) {
    switch (equipment.toLowerCase()) {
      case 'projecteur':
      case 'vidéoprojecteur':
        return Icons.videocam;
      case 'ordinateur':
        return Icons.computer;
      case 'connexion wi-fi':
        return Icons.wifi;
      case 'tableau blanc':
      case 'tableau noir':
        return Icons.dashboard;
      case 'système audio':
        return Icons.speaker;
      case 'climatisation':
        return Icons.ac_unit;
      default:
        return Icons.devices;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec icône
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icône de la salle
                Container(
                  width: 48,
                  height: 48,
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
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Nom et localisation
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${room.building} • Étage ${room.floor}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Boutons d'action
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E88E5).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        color: const Color(0xFF1E88E5),
                        onPressed: onEdit,
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.delete, size: 18),
                        color: const Color(0xFFE53935),
                        onPressed: onDelete,
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Capacité
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E88E5).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.people, size: 14, color: Color(0xFF1E88E5)),
                ),
                const SizedBox(width: 8),
                Text(
                  'Capacité: ${room.capacity} personnes',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            
            // Équipements
            if (room.equipment.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: room.equipment
                    .map((eq) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF5E35B1).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF5E35B1).withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getEquipmentIcon(eq),
                                size: 12,
                                color: const Color(0xFF5E35B1),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                eq,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF5E35B1),
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}