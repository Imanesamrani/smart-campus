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
    super.dispose();
  }

  Future<void> _loadData() async {
    await _roomController.loadRooms();
    await _roomController.loadAvailableOptions();
    await _userController.loadUsers();
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
                backgroundColor: Colors.green,
              ),
            );
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ Erreur: ${_roomController.error}'),
                backgroundColor: Colors.red,
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
                backgroundColor: Colors.green,
              ),
            );
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ Erreur: ${_roomController.error}'),
                backgroundColor: Colors.red,
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
        title: const Text('Confirmation'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette salle ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await _roomController.deleteRoom(roomId);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Salle supprimée avec succès'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Erreur: ${_roomController.error}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.red),
            ),
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
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 64, color: Colors.red.shade300),
              const SizedBox(height: 16),
              const Text(
                'Accès refusé',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Vous n\'avez pas les permissions d\'administrateur',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard - Gestion des Salles'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Consumer<RoomController>(
        builder: (context, roomController, child) {
          if (roomController.isLoading && roomController.rooms.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (roomController.rooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.meeting_room_outlined,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune salle disponible',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _openAddRoomDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter une salle'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: roomController.rooms.length,
            itemBuilder: (context, index) {
              final room = roomController.rooms[index];
              return _RoomCard(
                room: room,
                onEdit: () => _openEditRoomDialog(room),
                onDelete: () => _deleteRoom(room.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddRoomDialog,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            '${room.building} - Étage ${room.floor}',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.people, size: 18, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Text(
                  'Capacité: ${room.capacity} personnes',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
            if (room.equipment.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: room.equipment
                    .map((eq) => Chip(
                          label: Text(eq),
                          backgroundColor: Colors.blue.shade100,
                          labelStyle: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 12,
                          ),
                          padding: EdgeInsets.zero,
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  color: Colors.blue,
                  onPressed: onEdit,
                  iconSize: 20,
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                  onPressed: onDelete,
                  iconSize: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
