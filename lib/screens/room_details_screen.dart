import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/room_model.dart';
import '../controllers/favorite_controller.dart';
import '../controllers/auth_controller.dart';
import '../screens/map_screen.dart';
class RoomDetailsScreen extends StatefulWidget {
  final RoomModel room;

  const RoomDetailsScreen({
    super.key,
    required this.room,
  });

  @override
  State<RoomDetailsScreen> createState() => _RoomDetailsScreenState();
}

class _RoomDetailsScreenState extends State<RoomDetailsScreen> {
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

  void _toggleFavorite() async {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Retiré des favoris')),
      );
    } else {
      await favoriteController.addFavorite(
        roomId: widget.room.id,
        roomName: widget.room.name,
        building: widget.room.building,
        capacity: widget.room.capacity,
        equipment: widget.room.equipment,
      );
      setState(() => _isFavorite = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❤️ Ajouté aux favoris')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la salle'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🎨 En-tête avec info principale
            Container(
              color: Colors.blue.shade50,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.room.name,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.location_on,
                                    color: Colors.blue.shade600),
                                const SizedBox(width: 8),
                                Text(
                                  '${widget.room.building} - Étage ${widget.room.floor}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // ❤️ Bouton favoris (icône uniquement)
                      IconButton(
                        onPressed: _toggleFavorite,
                        icon: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite ? Colors.red : Colors.grey,
                          size: 28,
                        ),
                        tooltip: _isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 🗺️ Boutons Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                children: [
                  // Bouton Voir sur la carte
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapScreen(
                            targetBuildingName: widget.room.building,
                          ),
                        ),
                      );
                    },
                      icon: const Icon(Icons.map),
                      label: const Text('Voir sur la carte'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Bouton Voir en AR
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🔮 Ouverture de la vue AR...'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.view_in_ar),
                      label: const Text('Voir en AR'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // 👥 Capacité
            _InfoSection(
              icon: Icons.people,
              title: 'Capacité d\'accueil',
              content: '${widget.room.capacity} personnes',
              color: Colors.blue,
            ),
            const SizedBox(height: 20),

            // 📝 Description
            if (widget.room.description.isNotEmpty) ...[
                    _InfoSection(
                      icon: Icons.description,
                      title: 'Description',
                      content: widget.room.description,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 20),
                  ],

                  // 🎛️ Équipements
                  if (widget.room.equipment.isNotEmpty) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                  Row(
                    children: [
                      Icon(Icons.devices, color: Colors.purple),
                      const SizedBox(width: 12),
                      const Text(
                        'Équipements disponibles',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.room.equipment
                        .map(
                          (equipment) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getEquipmentIcon(equipment),
                                  size: 16,
                                  color: Colors.purple.shade600,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  equipment,
                                  style: TextStyle(
                                    color: Colors.purple.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],

            // 📍 Localisation
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.shade200,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.map, color: Colors.blue.shade600),
                      const SizedBox(width: 12),
                      const Text(
                        'Localisation',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _LocationInfo(label: 'Bâtiment', value: widget.room.building),
                  const SizedBox(height: 8),
                  _LocationInfo(label: 'Étage', value: 'Étage ${widget.room.floor}'),
                  const SizedBox(height: 8),
                  _LocationInfo(
                    label: 'Salle',
                    value: widget.room.name,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ⏰ Informations de mise à jour
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Créée le',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy')
                            .format(widget.room.createdAt),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dernière modification',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy HH:mm')
                            .format(widget.room.updatedAt),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
}

// 🎨 Section d'information avec icône
class _InfoSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Color color;

  const _InfoSection({
    required this.icon,
    required this.title,
    required this.content,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// 📍 Informations de localisation
class _LocationInfo extends StatelessWidget {
  final String label;
  final String value;

  const _LocationInfo({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
