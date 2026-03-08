import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/favorite_controller.dart';
import '../models/favorite_model.dart';
import 'room_details_screen.dart';
import '../models/room_model.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedBuilding = '';
  List<FavoriteModel> _filteredFavorites = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterFavorites);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterFavorites() {
    final favoriteController = context.read<FavoriteController>();
    List<FavoriteModel> filtered = favoriteController.favorites;

    // Filtrer par bâtiment
    if (_selectedBuilding.isNotEmpty) {
      filtered = filtered.where((fav) => fav.building == _selectedBuilding).toList();
    }

    // Filtrer par recherche
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered
          .where((fav) =>
              fav.roomName.toLowerCase().contains(query) ||
              fav.building.toLowerCase().contains(query))
          .toList();
    }

    setState(() {
      _filteredFavorites = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes favoris'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Consumer<FavoriteController>(
        builder: (context, favoriteController, _) {
          if (favoriteController.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final favorites = _filteredFavorites.isEmpty ? favoriteController.favorites : _filteredFavorites;

          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun favori pour le moment',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ajoutez des salles à vos favoris pour les retrouver facilement',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // 🔍 Barre de recherche
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Rechercher une salle...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // 🏢 Filtre par bâtiment
                      if (favoriteController.getAvailableBuildings().isNotEmpty) ...[
                        SizedBox(
                          height: 50,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 0, right: 8),
                                child: FilterChip(
                                  label: const Text('Tous les bâtiments'),
                                  selected: _selectedBuilding.isEmpty,
                                  onSelected: (_) {
                                    setState(() {
                                      _selectedBuilding = '';
                                    });
                                    _filterFavorites();
                                  },
                                ),
                              ),
                              ...favoriteController.getAvailableBuildings().map((building) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    label: Text(building),
                                    selected: _selectedBuilding == building,
                                    onSelected: (_) {
                                      setState(() {
                                        _selectedBuilding = building;
                                      });
                                      _filterFavorites();
                                    },
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // 📋 Liste des favoris
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      final favorite = favorites[index];
                      return _FavoriteCard(
                        favorite: favorite,
                        onRemove: () {
                          favoriteController.removeFavorite(favorite.roomId);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}

// 🎨 Carte de favori personnalisée
class _FavoriteCard extends StatelessWidget {
  final FavoriteModel favorite;
  final VoidCallback onRemove;

  const _FavoriteCard({
    required this.favorite,
    required this.onRemove,
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Naviguer vers les détails de la salle
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RoomDetailsScreen(
                room: RoomModel(
                  id: favorite.roomId,
                  name: favorite.roomName,
                  building: favorite.building,
                  floor: 0,
                  capacity: favorite.capacity,
                  equipment: favorite.equipment,
                  description: '',
                  isAvailable: true,
                  createdAt: favorite.addedAt,
                  updatedAt: favorite.addedAt,
                ),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🏷️ Nom et bâtiment
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          favorite.roomName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 16, color: Colors.blue.shade600),
                            const SizedBox(width: 4),
                            Text(
                              favorite.building,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite),
                    color: Colors.red,
                    onPressed: onRemove,
                    tooltip: 'Retirer des favoris',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 👥 Capacité
              Row(
                children: [
                  Icon(Icons.people, size: 18, color: Colors.blue.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Capacité: ${favorite.capacity} personnes',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
              // 🎛️ Équipements
              if (favorite.equipment.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: favorite.equipment
                      .map((eq) => Chip(
                            label: Text(eq),
                            backgroundColor: Colors.blue.shade100,
                            labelStyle: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 12,
                            ),
                            avatar: Icon(
                              _getEquipmentIcon(eq),
                              size: 16,
                              color: Colors.blue.shade700,
                            ),
                            padding: EdgeInsets.zero,
                          ))
                      .toList(),
                ),
              ],
              const SizedBox(height: 12),
              // ⏰ Date d'ajout
              Text(
                'Ajouté le ${favorite.addedAt.day}/${favorite.addedAt.month}/${favorite.addedAt.year}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
