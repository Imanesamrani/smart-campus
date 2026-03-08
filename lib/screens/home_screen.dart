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
import 'admin_timetable_home_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final user = authController.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Campus'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          // Menu utilisateur
          PopupMenuButton<String>(
            icon: CircleAvatar(
              backgroundColor: Colors.blue.shade200,
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : null,
              child: user?.photoURL == null
                  ? Text(
                      user?.displayName[0].toUpperCase() ?? 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            onSelected: (value) async {
              if (value == 'logout') {
                await authController.logout();
              } else if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person),
                    const SizedBox(width: 8),
                    Text('Profil (${user?.role})'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Paramètres'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Déconnexion', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: user != null
          ? _buildDashboard(context, user)
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildDashboard(BuildContext context, UserModel user) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue[50]!,
            Colors.white,
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Message de bienvenue personnalisé
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue[100],
                      backgroundImage: user.photoURL != null
                          ? NetworkImage(user.photoURL!)
                          : null,
                      child: user.photoURL == null
                          ? Text(
                              user.displayName[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: 30,
                                color: Colors.blue[800],
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bonjour, ${user.displayName}!',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getRoleMessage(user.role),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (user.role == 'étudiant' && user.filiere != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Filière: ${user.filiere}',
                                    style: TextStyle(
                                      color: Colors.blue[800],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'Niveau: ${user.niveau}',
                                    style: TextStyle(
                                      color: Colors.blue[800],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Section des fonctionnalités principales (Personne 1)
            const Text(
              'Gestion des salles',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              icon: Icons.meeting_room,
              title: 'Liste des salles',
              subtitle: 'Voir toutes les salles disponibles du campus',
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RoomsListScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            _buildFeatureCard(
              icon: Icons.favorite,
              title: 'Mes favoris',
              subtitle: 'Accéder à vos salles préférées',
              color: Colors.red,
              onTap: () {
                // Initialiser le FavoriteController avec l'ID de l'utilisateur
                final favoriteController = context.read<FavoriteController>();
                favoriteController.setUserId(user.uid);
                favoriteController.loadFavorites();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavoritesScreen(),
                  ),
                );
              },
            ),
            if (user.role == 'admin') ...[
              const SizedBox(height: 20),
              const Text(
                'Gestion Administrative',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildFeatureCard(
                icon: Icons.people_outline,
                title: 'Gérer les Utilisateurs',
                subtitle: 'Consulter, modifier ou supprimer des utilisateurs',
                color: Colors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserManagementScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              _buildFeatureCard(
                icon: Icons.meeting_room,
                title: 'Gérer les Salles',
                subtitle: 'Ajouter, modifier ou supprimer des salles',
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminDashboardScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              _buildFeatureCard(
                icon: Icons.schedule,
                title: 'Gérer les emplois du temps',
                subtitle: 'Importer et gérer les emplois du temps',
                color: Colors.deepPurple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminTimetableHomeScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              
            ],
          ],
        ),
      ),
    );
  }

  String _getRoleMessage(String role) {
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

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}