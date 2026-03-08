import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/user_controller.dart';
import '../models/user_model.dart';
import 'user_form_dialog.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Charger les utilisateurs après le build
    Future.microtask(() {
      context.read<UserController>().loadUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => UserFormDialog(
        isNewUser: true,
        onSave: (userData) async {
          final userController = context.read<UserController>();
          final success = await userController.createUser(
            email: userData['email'],
            password: userData['password'],
            displayName: userData['displayName'],
            role: userData['role'],
            filiere: userData['filiere'],
            niveau: userData['niveau'],
          );

          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Utilisateur créé avec succès'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ Erreur: ${userController.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  void _openEditUserDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => UserFormDialog(
        initialUser: user,
        isNewUser: false,
        onSave: (userData) async {
          final userController = context.read<UserController>();
          final success = await userController.updateUser(
            user.uid,
            displayName: userData['displayName'],
            role: userData['role'],
            filiere: userData['filiere'],
            niveau: userData['niveau'],
          );

          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Utilisateur modifié avec succès'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ Erreur: ${userController.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  void _deleteUser(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: Text(
            'Êtes-vous sûr de vouloir supprimer l\'utilisateur "${user.displayName}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final userController = context.read<UserController>();
              final success = await userController.deleteUser(user.uid);

              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Utilisateur supprimé avec succès'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Erreur: ${userController.error}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Utilisateurs'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Consumer<UserController>(
        builder: (context, userController, _) {
          // Si les données sont en cours de chargement et la liste est vide
          if (userController.isLoading && userController.users.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Chargement des utilisateurs...'),
                ],
              ),
            );
          }

          // S'il y a une erreur
          if (userController.error != null && userController.users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur: ${userController.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red[700]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      userController.loadUsers();
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          // Si la liste est vide
          if (userController.users.isEmpty && !userController.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucun utilisateur trouvé',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      userController.loadUsers();
                    },
                    child: const Text('Charger les utilisateurs'),
                  ),
                ],
              ),
            );
          }

          // Afficher la liste des utilisateurs
          return Column(
            children: [
              // 📊 Statistiques
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${userController.users.length} utilisateur${userController.users.length != 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              // 📋 Liste des utilisateurs
              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: userController.users.length,
                  itemBuilder: (context, index) {
                    final user = userController.users[index];
                    return _UserCard(
                      user: user,
                      onEdit: () => _openEditUserDialog(user),
                      onDelete: () => _deleteUser(user),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddUserDialog,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.person_add),
      ),
    );
  }
}

// 🎨 Carte utilisateur
class _UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _UserCard({
    required this.user,
    required this.onEdit,
    required this.onDelete,
  });

  String _getRoleLabel(String role) {
    switch (role) {
      case 'étudiant':
        return '👨‍🎓 Étudiant';
      case 'enseignant':
        return '👨‍🏫 Enseignant';
      case 'admin':
        return '⚙️ Administrateur';
      default:
        return role;
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'étudiant':
        return Colors.blue;
      case 'enseignant':
        return Colors.orange;
      case 'admin':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec nom et rôle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getRoleColor(user.role).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getRoleLabel(user.role),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getRoleColor(user.role),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Boutons d'action
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('Modifier'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Supprimer',
                              style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Détails utilisateur
            Column(
              children: [
                _DetailRow(
                  icon: Icons.email,
                  label: 'Email',
                  value: user.email,
                ),
                const SizedBox(height: 8),
                if (user.role == 'étudiant') ...[
                  _DetailRow(
                    icon: Icons.school,
                    label: 'Filière',
                    value: user.filiere ?? 'N/A',
                  ),
                  const SizedBox(height: 8),
                  _DetailRow(
                    icon: Icons.grade,
                    label: 'Niveau',
                    value: user.niveau ?? 'N/A',
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
