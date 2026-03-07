import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../models/user_model.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
          ? _buildDashboard(user)
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildDashboard(UserModel user) {
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
              'Recherche de salles',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              icon: Icons.search,
              title: 'Rechercher une salle',
              subtitle: 'Trouvez la salle idéale pour vos cours',
              color: Colors.blue,
              onTap: () {
                // Naviguer vers la recherche de salles
              },
            ),
            const SizedBox(height: 8),
            _buildFeatureCard(
              icon: Icons.meeting_room,
              title: 'Liste des salles',
              subtitle: 'Voir toutes les salles disponibles',
              color: Colors.green,
              onTap: () {
                // Naviguer vers la liste des salles
              },
            ),
            const SizedBox(height: 8),
            _buildFeatureCard(
              icon: Icons.favorite,
              title: 'Mes favoris',
              subtitle: '${user.favoriteRooms.length} salles favorites',
              color: Colors.red,
              onTap: () {
                // Naviguer vers les favoris
              },
            ),
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
            color: color.withValues(alpha: 0.1),
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