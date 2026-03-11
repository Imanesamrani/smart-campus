import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../controllers/favorite_controller.dart';
import '../models/user_model.dart';
import '../services/notification_service.dart';
import 'profile_screen.dart';
import 'rooms_list_screen.dart';
import 'favorites_screen.dart';
import 'user_management_screen.dart';
import 'admin_dashboard_screen.dart';
import 'jobs_screen.dart';
import 'admin_timetable_home_screen.dart';
import 'notifications_screen.dart';
import 'admin_announcements_screen.dart';
import 'announcement_screen.dart';
import 'my_timetables_screen.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authController = context.read<AuthController>();
      final favoriteController = context.read<FavoriteController>();

      if (authController.currentUser != null) {
        favoriteController.setUserId(authController.currentUser!.uid);
        favoriteController.loadFavorites();
      }
    });
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

  bool _showTimetableNotifications(UserModel user) {
    return user.role == 'étudiant' || user.role == 'enseignant';
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
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Bonjour, ${user.displayName}!',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                              overflow: TextOverflow.ellipsis,
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
                if (_showTimetableNotifications(user))
                  StreamBuilder<int>(
                    stream: NotificationService().unreadCount(user),
                    builder: (context, snapshot) {
                      final unreadCount = snapshot.data ?? 0;

                      return Stack(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.notifications_outlined,
                              color: Color(0xFF1E293B),
                            ),
                            tooltip: 'Notifications',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const NotificationsScreen(),
                                ),
                              );
                            },
                          ),
                          if (unreadCount > 0)
                            Positioned(
                              right: 6,
                              top: 6,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 18,
                                  minHeight: 18,
                                ),
                                child: Text(
                                  unreadCount > 9 ? '9+' : unreadCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Color(0xFF1E293B)),
                  onPressed: () async {
                    await context.read<AuthController>().logout();
                  },
                  tooltip: 'Déconnexion',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_showTimetableNotifications(user))
                  _buildTimetableNotificationCard(user),
                if (_showTimetableNotifications(user))
                  const SizedBox(height: 20),
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
                if (user.role == 'étudiant' && user.filiere != null)
                  _buildStudentInfoCard(user),
                const SizedBox(height: 16),
                _buildCampusInfoCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimetableNotificationCard(UserModel user) {
    return StreamBuilder<int>(
      stream: NotificationService().unreadCount(user),
      builder: (context, snapshot) {
        final unreadCount = snapshot.data ?? 0;

        if (unreadCount == 0) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF5E35B1),
                Color(0xFF7E57C2),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5E35B1).withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.schedule,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nouvelle mise à jour disponible',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      unreadCount == 1
                          ? 'Vous avez 1 notification liée à votre emploi du temps.'
                          : 'Vous avez $unreadCount notifications liées à votre emploi du temps.',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF5E35B1),
                  minimumSize: const Size(90, 42),
                ),
                child: const Text('Voir'),
              ),
            ],
          ),
        );
      },
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

    if (user.role == 'étudiant' || user.role == 'enseignant') {
      features.addAll([
        _FeatureItem(
          icon: Icons.campaign,
          title: 'Mes annonces',
          subtitle: 'Voir les annonces qui vous concernent',
          color: const Color(0xFFFF9800),
          route: const AnnouncementScreen(),
          isEnabled: true,
        ),
        
        _FeatureItem(
          icon: Icons.schedule,
          title: 'Mes emplois',
          subtitle: 'Consulter mon emploi du temps',
          color: const Color(0xFF5E35B1),
          route: const MyTimetablesScreen(),
          isEnabled: true,
        ),
      ]);
    }

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
          icon: Icons.schedule,
          title: 'Gérer les emplois du temps',
          subtitle: 'Importer et gérer les emplois du temps',
          color: const Color(0xFF5E35B1),
          route: const AdminTimetableHomeScreen(),
          isEnabled: true,
        ),
        _FeatureItem(
          icon: Icons.work,
          title: 'Gérer les Emplois',
          subtitle: 'Ajouter et modifier les emplois (Bientôt disponible)',
          color: const Color(0xFF00897B),
          route: const JobsScreen(),
          isEnabled: false,
        ),
        _FeatureItem(
          icon: Icons.notifications,
          title: 'Gérer les Annonces',
          subtitle: 'Publier, modifier et supprimer les annonces',
          color: const Color(0xFFFFB300),
          route: const AdminAnnouncementsScreen(),
          isEnabled: true,
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
          onTap: feature.isEnabled
              ? () {
                  if (feature.route is FavoritesScreen) {
                    final favoriteController = context.read<FavoriteController>();
                    favoriteController.setUserId(user.uid);
                    favoriteController.loadFavorites();
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => feature.route),
                  );
                }
              : null,
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
                  'Consultez régulièrement vos annonces et notifications académiques.',
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