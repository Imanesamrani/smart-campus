import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final List<Map<String, String>> announcements = [
    {
      'title': 'Maintenance des salles A et B',
      'content': 'Les salles A et B seront fermées ce weekend pour maintenance.',
      'date': DateTime.now().subtract(const Duration(days: 1)).toString(),
      'author': 'Administrateur IT',
      'category': 'Maintenance'
    },
    {
      'title': 'Nouvelle année académique',
      'content':
          'Bienvenue à tous les nouveaux et anciens étudiants pour cette nouvelle année.',
      'date': DateTime.now().toString(),
      'author': 'Direction',
      'category': 'Général'
    },
    {
      'title': 'Réunion d\'orientation',
      'content':
          'Les nouveaux étudiants sont invités à la réunion d\'orientation le 15 septembre.',
      'date': DateTime.now().subtract(const Duration(days: 2)).toString(),
      'author': 'RH',
      'category': 'Événement'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Annonces'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAnnouncementDialog(context),
        backgroundColor: const Color(0xFF0066CC),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: announcements.length,
        itemBuilder: (context, index) {
          final announcement = announcements[index];
          return _buildAnnouncementCard(announcement, index);
        },
      ),
    );
  }

  Widget _buildAnnouncementCard(Map<String, String> announcement, int index) {
    final date = DateTime.parse(announcement['date'] ?? DateTime.now().toString());
    final formattedDate = DateFormat('dd/MM/yyyy à HH:mm').format(date);

    final categoryColors = {
      'Maintenance': Colors.orange,
      'Général': Colors.blue,
      'Événement': Colors.green,
    };

    final categoryColor =
        categoryColors[announcement['category']] ?? Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    announcement['title'] ?? 'Annonce',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    announcement['category'] ?? 'N/A',
                    style: TextStyle(
                      color: categoryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              announcement['content'] ?? 'Aucun contenu',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Text(
                  announcement['author'] ?? 'Inconnu',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Text(
                  formattedDate,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showAnnouncementDialog(context, announcement, index),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Modifier'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF0066CC),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _deleteAnnouncement(index),
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Supprimer'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAnnouncementDialog(
    BuildContext context, [
    Map<String, String>? announcement,
    int? index,
  ]) {
    final titleController =
        TextEditingController(text: announcement?['title'] ?? '');
    final contentController =
        TextEditingController(text: announcement?['content'] ?? '');
    final authorController =
        TextEditingController(text: announcement?['author'] ?? '');
    String selectedCategory = announcement?['category'] ?? 'Général';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(announcement == null
            ? 'Ajouter une annonce'
            : 'Modifier l\'annonce'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'Contenu',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: authorController,
                decoration: const InputDecoration(
                  labelText: 'Auteur',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Catégorie',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Maintenance', child: Text('Maintenance')),
                  DropdownMenuItem(value: 'Général', child: Text('Général')),
                  DropdownMenuItem(value: 'Événement', child: Text('Événement')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    selectedCategory = value;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              if (announcement == null) {
                announcements.add({
                  'title': titleController.text,
                  'content': contentController.text,
                  'author': authorController.text,
                  'category': selectedCategory,
                  'date': DateTime.now().toString(),
                });
              } else {
                announcements[index!] = {
                  'title': titleController.text,
                  'content': contentController.text,
                  'author': authorController.text,
                  'category': selectedCategory,
                  'date': announcement['date'] ?? DateTime.now().toString(),
                };
              }
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _deleteAnnouncement(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette annonce?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                announcements.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
