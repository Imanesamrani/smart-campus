import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/announcement_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/favorite_controller.dart';
import '../models/user_model.dart';
import '../services/AR_Notification/notification_service.dart';
import 'AR_Notification/ar_scan_screen.dart';
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

  String _normalizeRole(String role) {
    final normalized = role.trim().toLowerCase();

    if (normalized == 'admin' || normalized == 'administrateur') {
      return 'admin';
    }
    if (normalized == 'enseignant' || normalized == 'teacher') {
      return 'enseignant';
    }
    if (normalized == 'etudiant' ||
        normalized == 'étudiant' ||
        normalized == 'student' ||
        normalized == 'utilisateur' ||
        normalized == 'user') {
      return 'etudiant';
    }

    return normalized;
  }

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

  Future<void> _refreshAnnouncements() async {
    final authController = context.read<AuthController>();
    final currentUser = authController.currentUser;

    if (currentUser == null) return;

    await context.read<AnnouncementController>().loadAnnouncementsForUser(
      role: currentUser.role,
      filiere: currentUser.filiere,
      niveau: currentUser.niveau,
    );
  }

  String _getRoleLabel(String role) {
    switch (_normalizeRole(role)) {
      case 'etudiant':
        return 'Étudiant';
      case 'enseignant':
        return 'Enseignant';
      case 'admin':
        return 'Administrateur';
      default:
        return 'Utilisateur';
    }
  }

  List<_FeatureItem> _buildFeatureItems(UserModel user) {
    if (_normalizeRole(user.role) == 'admin') {
      return const [
        _FeatureItem(
          icon: Icons.meeting_room,
          title: 'Liste des salles',
          subtitle: 'Voir toutes les salles disponibles',
          color: Color(0xFF3B82F6),
          route: RoomsListScreen(),
        ),
        _FeatureItem(
          icon: Icons.favorite,
          title: 'Mes favoris',
          subtitle: 'Accéder à vos salles préférées',
          color: Color(0xFFEF4444),
          route: FavoritesScreen(),
        ),
        _FeatureItem(
          icon: Icons.blur_on,
          title: 'Campus 3D',
          subtitle: 'Ouvrir le campus Unity',
          color: Color(0xFF14B8A6),
          route: CampusDigitalTwinScreen(),
        ),
        _FeatureItem(
          icon: Icons.group,
          title: 'Gérer les utilisateurs',
          subtitle: 'Administration des comptes',
          color: Color(0xFFA855F7),
          route: UserManagementScreen(),
        ),
        _FeatureItem(
          icon: Icons.dashboard_customize,
          title: 'Gérer les salles',
          subtitle: 'Ajouter et modifier des salles',
          color: Color(0xFFF59E0B),
          route: AdminDashboardScreen(),
        ),
        _FeatureItem(
          icon: Icons.schedule,
          title: 'Gérer les emplois du temps',
          subtitle: 'Import et gestion des emplois',
          color: Color(0xFF8B5CF6),
          route: AdminTimetableHomeScreen(),
        ),
        _FeatureItem(
          icon: Icons.work_outline,
          title: 'Gérer les emplois',
          subtitle: 'Annoncer les postes ouverts',
          color: Color(0xFF10B981),
          route: JobsScreen(),
        ),
        _FeatureItem(
          icon: Icons.campaign,
          title: 'Gérer les annonces',
          subtitle: 'Publier, éditer et planifier les annonces',
          color: Color(0xFFEAB308),
          route: AdminAnnouncementsScreen(),
        ),
      ];
    }

    return const [
      _FeatureItem(
        icon: Icons.meeting_room,
        title: 'Liste des salles',
        subtitle: 'Voir toutes les salles disponibles',
        color: Color(0xFF3B82F6),
        route: RoomsListScreen(),
      ),
      _FeatureItem(
        icon: Icons.favorite,
        title: 'Mes favoris',
        subtitle: 'Accéder à vos salles préférées',
        color: Color(0xFFEF4444),
        route: FavoritesScreen(),
      ),
      _FeatureItem(
        icon: Icons.blur_on,
        title: 'Campus 3D',
        subtitle: 'Ouvrir le campus Unity',
        color: Color(0xFF14B8A6),
        route: CampusDigitalTwinScreen(),
      ),
      _FeatureItem(
        icon: Icons.campaign,
        title: 'Mes annonces',
        subtitle: 'Voir les annonces qui vous concernent',
        color: Color(0xFFF59E0B),
        route: AnnouncementScreen(),
      ),
      _FeatureItem(
        icon: Icons.schedule,
        title: 'Mes emplois',
        subtitle: 'Consulter mon emploi du temps',
        color: Color(0xFF8B5CF6),
        route: MyTimetablesScreen(),
      ),
    ];
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
        selectedItemColor: const Color(0xFF3B82F6),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          if (index == 2) {
            _refreshAnnouncements();
          }
          if (index == 3) {
            _ensureFavoritesLoaded(forceReload: true);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            label: 'Annonces',
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
        return const ArScanScreen();
      case 2:
        return const AnnouncementScreen();
      case 3:
        return const FavoritesScreen();
      case 4:
        return const ProfileScreen();
      default:
        return _buildDashboard(context, user);
    }
  }

  Widget _buildDashboard(BuildContext context, UserModel user) {
    final items = _buildFeatureItems(user);

    return SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 16, 10),
            color: Colors.white,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF3B82F6),
                  child: Text(
                    user.displayName.isNotEmpty
                        ? user.displayName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bonjour, ${user.displayName} !',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDBEAFE),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _getRoleLabel(user.role),
                          style: const TextStyle(
                            color: Color(0xFF2563EB),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
                        isLabelVisible: true,
                        label: Text('$count'),
                        child: const Icon(
                          Icons.notifications_none,
                          color: Color(0xFF334155),
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  onPressed: () => context.read<AuthController>().logout(),
                  icon: const Icon(Icons.logout, color: Color(0xFF334155)),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_normalizeRole(user.role) != 'admin') ...[
                    _buildMetaverseCard(context),
                    const SizedBox(height: 18),
                  ],
                  const Text(
                    'Fonctionnalités principales',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 14),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.92,
                    ),
                    itemBuilder: (context, index) =>
                        _buildFeatureCard(context, items[index]),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFDCFCE7)),
                    ),
                    child: const Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: Color(0xFF22C55E),
                          child: Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Consultez régulièrement vos annonces et notifications académiques.',
                            style: TextStyle(
                              color: Color(0xFF4B5563),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F4C81), Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'ENSIASD - Taroudant',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Campus immersif 3D',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Explorez le campus, ciblez un bâtiment ou une salle, puis lancez la scène Unity du metaverse directement depuis l'application.",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CampusDigitalTwinScreen(),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0F4C81),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.blur_on),
              label: const Text(
                'Ouvrir le campus Unity',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, _FeatureItem item) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => item.route),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: const Color(0xFFF1F5F9),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(item.icon, color: item.color, size: 22),
            ),
            const Spacer(),
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                color: Color(0xFF6B7280),
                height: 1.3,
              ),
            ),
          ],
        ),
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

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.route,
  });
}


