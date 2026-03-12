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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Mes favoris',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: Consumer<FavoriteController>(
        builder: (context, favoriteController, _) {
          if (favoriteController.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E88E5)),
              ),
            );
          }

          final favorites = _filteredFavorites.isEmpty ? favoriteController.favorites : _filteredFavorites;

          if (favorites.isEmpty) {
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
                        Icons.favorite_border,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Aucun favori pour le moment',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
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
                        decoration: InputDecoration(
                          hintText: 'Rechercher une salle...',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF1E293B)),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    _filterFavorites();
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
                    
                    // 🏢 Filtre par bâtiment
                    if (favoriteController.getAvailableBuildings().isNotEmpty) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _buildFilterChip(
                              label: 'Tous',
                              selected: _selectedBuilding.isEmpty,
                              onSelected: (_) {
                                setState(() {
                                  _selectedBuilding = '';
                                });
                                _filterFavorites();
                              },
                            ),
                            ...favoriteController.getAvailableBuildings().map((building) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: _buildFilterChip(
                                  label: building,
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
                    
                    // Résultats trouvés
                    if (favorites.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${favorites.length} favori${favorites.length != 1 ? 's' : ''}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            'Total: ${favorites.fold<int>(0, (sum, fav) => sum + fav.capacity)} places',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // 📋 Liste des favoris
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final favorite = favorites[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _FavoriteCard(
                        favorite: favorite,
                        onRemove: () {
                          favoriteController.removeFavorite(favorite.roomId);
                          _filterFavorites();
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
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
    return GestureDetector(
      onTap: () {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🏷️ En-tête avec nom et bouton de suppression
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icône
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFE53935),
                          Color(0xFFC62828),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Nom et bâtiment
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          favorite.roomName,
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
                                favorite.building,
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
                  
                  // Bouton de suppression
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red, size: 18),
                      onPressed: onRemove,
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                      tooltip: 'Retirer des favoris',
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 👥 Capacité
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E88E5).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.people, 
                      size: 16, 
                      color: Color(0xFF1E88E5)
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Capacité: ${favorite.capacity} personnes',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
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
              
              const SizedBox(height: 12),
              
              // ⏰ Date d'ajout
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 12,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Ajouté le ${favorite.addedAt.day}/${favorite.addedAt.month}/${favorite.addedAt.year}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}