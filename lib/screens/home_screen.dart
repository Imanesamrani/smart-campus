import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../controllers/favorite_controller.dart';
import '../models/user_model.dart';
import '../services/AR_Notification/notification_service.dart';
import 'AR_Notification/ar_scan_screen.dart';
import 'AR_Notification/avatar_viewer_screen.dart';
import 'AR_Notification/campus_digital_twin_screen.dart';
import 'AR_Notification/notifications_screen.dart';
import 'admin_announcements_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_timetable_home_screen.dart';
import 'announcement_screen.dart';
import 'favorites_screen.dart';
import 'jobs_screen.dart';
import 'my_timetables_screen.dart';
import 'profile_screen.dart';
import 'rooms_list_screen.dart';
import 'user_management_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? _favoritesLoadedForUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureFavoritesLoaded();
    });
  }

  void _ensureFavoritesLoaded({bool forceReload = false}) {
    final authController = context.read<AuthController>();
    final favoriteController = context.read<FavoriteController>();
    final currentUser = authController.currentUser;

    if (currentUser == null) return;

    favoriteController.setUserId(currentUser.uid);

    if (!forceReload && _favoritesLoadedForUserId == currentUser.uid) return;

    _favoritesLoadedForUserId = currentUser.uid;
    favoriteController.loadFavorites();
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
        onTap: (index) {
          setState(() => _selectedIndex = index);
          if (index == 3) {
            _ensureFavoritesLoaded(forceReload: true);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(
            icon: Icon(Icons.meeting_room),
            label: 'Salles',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoris',
          ),
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
        return const ArScanScreen();
      case 3:
        return const FavoritesScreen();
      case 4:
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
            padding: const EdgeInsets.fromLTRB(20, 50, 10, 20),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AvatarViewerScreen(user: user),
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFF1E88E5),
                    child: user.photoURL != null
                        ? ClipOval(
                            child: Image.network(
                              user.photoURL!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Text(
                            user.displayName[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bonjour, ${user.displayName}!',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        _getRoleLabel(user.role),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                StreamBuilder<int>(
                  stream: NotificationService().unreadCount(user),
                  builder: (context, snapshot) {
                    final count = snapshot.data ?? 0;
                    return IconButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationsScreen(),
                        ),
                      ),
                      icon: Badge(
                        label: Text('$count'),
                        backgroundColor: count > 0 ? Colors.red : Colors.grey,
                        child: const Icon(
                          Icons.notifications_outlined,
                          size: 28,
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => context.read<AuthController>().logout(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildMetaverseCard(context),
                const SizedBox(height: 24),
                _buildMainFeatureGrid(user),
                const SizedBox(height: 24),
                if (user.role == 'étudiant' && user.filiere != null)
                  _buildStudentInfoCard(user),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaverseCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CAMPUS METAVERSE',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Explorez le jumeau numérique 3D et l\'état des salles en direct.',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CampusDigitalTwinScreen(),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
            ),
            child: const Text('ENTRER DANS LE METAVERSE'),
          ),
        ],
      ),
    );
  }

  Widget _buildMainFeatureGrid(UserModel user) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        _buildGridItem(
          Icons.meeting_room,
          'Salles',
          'Toutes les salles',
          Colors.blue,
          const RoomsListScreen(),
        ),
        _buildGridItem(
          Icons.favorite,
          'Favoris',
          'Mes préférés',
          Colors.red,
          const FavoritesScreen(),
        ),
        _buildGridItem(
          Icons.campaign,
          'Annonces',
          'Mes messages',
          Colors.orange,
          const AnnouncementScreen(),
        ),
        _buildGridItem(
          Icons.schedule,
          'Emplois',
          'Mon planning',
          Colors.purple,
          const MyTimetablesScreen(),
        ),
      ],
    );
  }

  Widget _buildGridItem(
    IconData icon,
    String title,
    String sub,
    Color color,
    Widget route,
  ) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => route),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              sub,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentInfoCard(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[800],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.school, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filière: ${user.filiere}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Niveau: ${user.niveau}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCampusInfoCard() {
    return const SizedBox.shrink();
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
    this.isEnabled = true,
  });
}
