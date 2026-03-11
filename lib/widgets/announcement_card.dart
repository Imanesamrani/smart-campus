import 'package:flutter/material.dart';
import '../models/announcement.dart';

class AnnouncementCard extends StatelessWidget {
  final Announcement announcement;
  final bool isAdmin;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final ValueChanged<bool>? onToggleActive;

  const AnnouncementCard({
    super.key,
    required this.announcement,
    this.isAdmin = false,
    this.onEdit,
    this.onDelete,
    this.onToggleActive,
  });

  Color _getTypeColor(String type) {
    switch (type) {
      case 'urgent':
        return const Color(0xFFE53935);
      case 'académique':
        return const Color(0xFF1E88E5);
      case 'administratif':
        return const Color(0xFFFB8C00);
      case 'événement':
        return const Color(0xFF8E24AA);
      default:
        return const Color(0xFF546E7A);
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  String _formatRoles(List<String> roles) {
    if (roles.contains('tous')) return 'Tous';
    return roles.map((role) {
      switch (role) {
        case 'étudiant':
          return 'Étudiants';
        case 'enseignant':
          return 'Enseignants';
        case 'admin':
          return 'Admins';
        default:
          return role;
      }
    }).join(', ');
  }

  String _formatFilieres(List<String> filieres) {
    if (filieres.contains('tous')) return 'Toutes filières';
    return filieres.join(', ');
  }

  String _formatNiveaux(List<String> niveaux) {
    if (niveaux.contains('tous')) return 'Tous niveaux';
    return niveaux.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final color = _getTypeColor(announcement.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            announcement.title.isNotEmpty
                                ? announcement.title
                                : 'Sans titre',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        if (announcement.isPinned)
                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(
                              Icons.push_pin,
                              color: Color(0xFFFB8C00),
                              size: 18,
                            ),
                          ),
                        if (isAdmin)
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') onEdit?.call();
                              if (value == 'delete') onDelete?.call();
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('Modifier'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Supprimer'),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Vue utilisateur: seulement le type
                    // Vue admin: type + cible + filière + niveau + statut
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _chip(announcement.type, color),

                        if (isAdmin)
                          _chip(
                            _formatRoles(announcement.targetRoles),
                            const Color(0xFF1E88E5),
                          ),

                        if (isAdmin &&
                            announcement.targetRoles.contains('étudiant'))
                          _chip(
                            _formatFilieres(announcement.targetFilieres),
                            const Color(0xFF00897B),
                          ),

                        if (isAdmin &&
                            announcement.targetRoles.contains('étudiant'))
                          _chip(
                            _formatNiveaux(announcement.targetNiveaux),
                            const Color(0xFF8E24AA),
                          ),

                        if (isAdmin && !announcement.isActive)
                          _chip('Masquée', const Color(0xFFE53935)),
                      ],
                    ),

                    const SizedBox(height: 12),
                    Text(
                      announcement.message.isNotEmpty
                          ? announcement.message
                          : 'Aucun contenu disponible',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF475569),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          _formatDate(announcement.createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const Spacer(),
                        Flexible(
                          child: Text(
                            "Par ${announcement.author}",
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (isAdmin && onToggleActive != null) ...[
                      const SizedBox(height: 8),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Visible'),
                        value: announcement.isActive,
                        onChanged: onToggleActive,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}