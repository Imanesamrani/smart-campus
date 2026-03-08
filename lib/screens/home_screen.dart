import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../controllers/favorite_controller.dart';
import '../models/user_model.dart';
import 'profile_screen.dart';
import 'rooms_list_screen.dart';
import 'favorites_screen.dart';
import 'user_management_screen.dart';
import 'admin_dashboard_screen.dart';
import 'jobs_screen.dart';
import 'announcements_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialiser le FavoriteController avec l'ID de l'utilisateur
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authController = context.read<AuthController>();
      final favoriteController = context.read<FavoriteController>();

      if (authController.currentUser != null) {
        favoriteController.setUserId(authController.currentUser!.uid);
        favoriteController.loadFavorites();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'étudiant':
        return 'Étudiant';
      case 'enseignant':
        return 'Enseignant';
      case 'admin':
        return 'Administrateur';
      default:
        return 'Utilisateur';
    }
  }

  String _getRoleIcon(String role) {
    switch (role) {
      case 'étudiant':
        return '🎓';
      case 'enseignant':
        return '👨‍🏫';
      case 'admin':
        return '⚙️';
      default:
        return '👤';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final user = authController.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: user != null
          ? _buildBody(context, user)
          : const Center(child: CircularProgressIndicator()),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF1E88E5),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.meeting_room), label: 'Salles'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoris'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, UserModel user) {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard(context, user);
      case 1:
        return const RoomsListScreen();
      case 2:
        final favoriteController = context.read<FavoriteController>();
        favoriteController.setUserId(user.uid);
        favoriteController.loadFavorites();
        return const FavoritesScreen();
      case 3:
        return const ProfileScreen();
      default:
        return _buildDashboard(context, user);
    }
  }

  Widget _buildDashboard(BuildContext context, UserModel user) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header avec bienvenue et bouton de déconnexion intégré
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1E88E5),
                        Color(0xFF1565C0),
                      ],
                    ),
                    shape: BoxShape.circle,
                    image: user.photoURL != null
                        ? DecorationImage(
                            image: NetworkImage(user.photoURL!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: user.photoURL == null
                      ? Center(
                          child: Text(
                            user.displayName[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                
                // Informations utilisateur (prenant l'espace disponible)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Bonjour, ${user.displayName}!',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getRoleIcon(user.role),
                            style: const TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E88E5).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getRoleLabel(user.role),
                          style: const TextStyle(
                            color: Color(0xFF1E88E5),
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Bouton de déconnexion à droite
                IconButton(
                  icon: const Icon(Icons.logout, color: Color(0xFF1E293B)),
                  onPressed: () async {
                    await context.read<AuthController>().logout();
                  },
                  tooltip: 'Déconnexion',
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),

          // Menu principal
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section des fonctionnalités principales
                const Text(
                  'Fonctionnalités principales',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 16),
                _buildMainFeatureGrid(user),

                const SizedBox(height: 24),

                // Section d'information pour l'utilisateur
                if (user.role == 'étudiant' && user.filiere != null)
                  _buildStudentInfoCard(user),

                const SizedBox(height: 16),

                // Informations campus
                _buildCampusInfoCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainFeatureGrid(UserModel user) {
    final features = [
      _FeatureItem(
        icon: Icons.meeting_room,
        title: 'Liste des salles',
        subtitle: 'Voir toutes les salles disponibles',
        color: const Color(0xFF1E88E5),
        route: const RoomsListScreen(),
        isEnabled: true,
      ),
      _FeatureItem(
        icon: Icons.favorite,
        title: 'Mes favoris',
        subtitle: 'Accéder à vos salles préférées',
        color: const Color(0xFFE53935),
        route: const FavoritesScreen(),
        isEnabled: true,
      ),
    ];

    if (user.role == 'admin') {
      features.addAll([
        _FeatureItem(
          icon: Icons.people_outline,
          title: 'Gérer les Utilisateurs',
          subtitle: 'Administration des comptes',
          color: const Color(0xFF8E24AA),
          route: const UserManagementScreen(),
          isEnabled: true,
        ),
        _FeatureItem(
          icon: Icons.meeting_room,
          title: 'Gérer les Salles',
          subtitle: 'Ajouter, modifier des salles',
          color: const Color(0xFFFB8C00),
          route: const AdminDashboardScreen(),
          isEnabled: true,
        ),
        _FeatureItem(
          icon: Icons.work,
          title: 'Gérer les Emplois',
          subtitle: 'Ajouter et modifier les emplois (Bientôt disponible)',
          color: const Color(0xFF00897B),
          route: const JobsScreen(),
          isEnabled: false, // Désactivé - frontend uniquement
        ),
        _FeatureItem(
          icon: Icons.notifications,
          title: 'Gérer les Annonces',
          subtitle: 'Publier des annonces (Bientôt disponible)',
          color: const Color(0xFFFFB300),
          route: const AnnouncementsScreen(),
          isEnabled: false, // Désactivé - frontend uniquement
        ),
      ]);
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return _buildFeatureGridCard(
          icon: feature.icon,
          title: feature.title,
          subtitle: feature.subtitle,
          color: feature.color,
          isEnabled: feature.isEnabled,
          onTap: feature.isEnabled ? () {
            // Initialiser le FavoriteController pour la route des favoris
            if (feature.route is FavoritesScreen) {
              final favoriteController = context.read<FavoriteController>();
              favoriteController.setUserId(user.uid);
              favoriteController.loadFavorites();
            }
            
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => feature.route),
            );
          } : null, // Pas d'action si désactivé
        );
      },
    );
  }

  Widget _buildFeatureGridCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isEnabled,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icône avec opacité réduite si désactivé
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(isEnabled ? 0.1 : 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon, 
                      color: isEnabled ? color : color.withOpacity(0.3), 
                      size: 24,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isEnabled 
                              ? const Color(0xFF1E293B) 
                              : const Color(0xFF1E293B).withOpacity(0.3),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: isEnabled 
                              ? Colors.grey.shade600 
                              : Colors.grey.shade400,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Badge "Bientôt" pour les cartes désactivées
            if (!isEnabled)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Bientôt',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentInfoCard(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E88E5),
            Color(0xFF1565C0),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E88E5).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Informations académiques',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Filière', user.filiere ?? 'Non spécifié'),
                const SizedBox(height: 8),
                _buildInfoRow('Niveau', user.niveau ?? 'Non spécifié'),
                const SizedBox(height: 8),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.school,
              color: Colors.white,
              size: 48,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCampusInfoCard() {
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF43A047).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.info, color: Color(0xFF43A047)),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Info Campus',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Maintenance des salles A et B ce weekend',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Widget route;
  final bool isEnabled;

  _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.route,
    required this.isEnabled,
  });
}