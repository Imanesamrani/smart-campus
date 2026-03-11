import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/announcement_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/user_model.dart';
import '../widgets/announcement_card.dart';

class AnnouncementScreen extends StatefulWidget {
  const AnnouncementScreen({super.key});

  @override
  State<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthController>().currentUser;
      if (user != null) {
        context.read<AnnouncementController>().loadAnnouncementsForUser(
              role: user.role,
              filiere: user.filiere,
              niveau: user.niveau,
            );
      }
    });
  }

  Future<void> _refresh(UserModel user) async {
    await context.read<AnnouncementController>().loadAnnouncementsForUser(
          role: user.role,
          filiere: user.filiere,
          niveau: user.niveau,
        );
  }

  String _buildSubtitle(UserModel user) {
    if (user.role == 'étudiant') {
      final filiere = user.filiere ?? 'Filière non définie';
      final niveau = user.niveau ?? 'Niveau non défini';
      return '$filiere • $niveau';
    }

    if (user.role == 'enseignant') {
      return 'Annonces destinées aux enseignants';
    }

    return 'Informations importantes';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final controller = context.watch<AnnouncementController>();
    final user = auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Mes annonces',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _refresh(user),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF5E35B1),
                    Color(0xFF7E57C2),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5E35B1).withOpacity(0.20),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.campaign,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Centre des annonces',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _buildSubtitle(user),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${controller.announcements.length} annonce(s) disponible(s)',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Builder(
                builder: (_) {
                  if (controller.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (controller.errorMessage != null) {
                    return ListView(
                      children: [
                        const SizedBox(height: 100),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              controller.errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  if (controller.announcements.isEmpty) {
                    return ListView(
                      children: const [
                        SizedBox(height: 110),
                        Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.notifications_none,
                                size: 72,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 14),
                              Text(
                                'Aucune annonce pour le moment',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF475569),
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Les annonces qui vous concernent apparaîtront ici.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: controller.announcements.length,
                    itemBuilder: (context, index) {
                      final announcement = controller.announcements[index];
                      return AnnouncementCard(
                        announcement: announcement,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}