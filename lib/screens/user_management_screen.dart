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
  String? _selectedRole;
  List<String> _availableRoles = ['étudiant', 'enseignant', 'admin'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<UserController>().loadUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<UserModel> _filterUsers(List<UserModel> users) {
    return users.where((user) {
      // Filtre par recherche
      final matchesSearch = _searchController.text.isEmpty ||
          user.displayName.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchController.text.toLowerCase());
      
      // Filtre par rôle
      final matchesRole = _selectedRole == null || user.role == _selectedRole;
      
      return matchesSearch && matchesRole;
    }).toList();
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
                backgroundColor: Color(0xFF43A047),
              ),
            );
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ Erreur: ${userController.error}'),
                backgroundColor: const Color(0xFFE53935),
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
                backgroundColor: Color(0xFF43A047),
              ),
            );
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ Erreur: ${userController.error}'),
                backgroundColor: const Color(0xFFE53935),
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
        title: const Text(
          'Confirmation',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer l\'utilisateur "${user.displayName}" ?',
          style: const TextStyle(color: Color(0xFF1E293B)),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF1E88E5),
            ),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final userController = context.read<UserController>();
              final success = await userController.deleteUser(user.uid);

              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Utilisateur supprimé avec succès'),
                    backgroundColor: Color(0xFF43A047),
                  ),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Erreur: ${userController.error}'),
                    backgroundColor: const Color(0xFFE53935),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Gestion des Utilisateurs',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: Consumer<UserController>(
        builder: (context, userController, _) {
          // Si les données sont en cours de chargement et la liste est vide
          if (userController.isLoading && userController.users.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E88E5)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Chargement des utilisateurs...',
                    style: TextStyle(color: Color(0xFF1E293B)),
                  ),
                ],
              ),
            );
          }

          // S'il y a une erreur
          if (userController.error != null && userController.users.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Color(0xFFE53935),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Une erreur est survenue',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userController.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        userController.loadUsers();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E88E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Si la liste est vide
          if (userController.users.isEmpty && !userController.isLoading) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.people_outline,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Aucun utilisateur trouvé',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        userController.loadUsers();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E88E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Charger les utilisateurs'),
                    ),
                  ],
                ),
              ),
            );
          }

          final filteredUsers = _filterUsers(userController.users);

          // Afficher la liste des utilisateurs
          return Column(
            children: [
              // 🔍 Barre de recherche et filtres
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Champ de recherche
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Rechercher par nom ou email...',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF1E293B)),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.clear, color: Color(0xFF1E293B)),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    
                    // Filtre par rôle
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildFilterChip(
                            label: 'Tous',
                            selected: _selectedRole == null,
                            onSelected: (_) {
                              setState(() {
                                _selectedRole = null;
                              });
                            },
                          ),
                          ..._availableRoles.map((role) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: _buildFilterChip(
                                label: _getRoleLabel(role),
                                selected: _selectedRole == role,
                                onSelected: (_) {
                                  setState(() {
                                    _selectedRole = role;
                                  });
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    
                    // 📊 Statistiques
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${filteredUsers.length} utilisateur${filteredUsers.length != 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        // Statistiques par rôle
                        if (filteredUsers.isNotEmpty)
                          Text(
                            '👨‍🎓 ${filteredUsers.where((u) => u.role == 'étudiant').length}  |  '
                            '👨‍🏫 ${filteredUsers.where((u) => u.role == 'enseignant').length}  |  '
                            '⚙️ ${filteredUsers.where((u) => u.role == 'admin').length}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // 📋 Liste des utilisateurs
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _UserCard(
                        user: user,
                        onEdit: () => _openEditUserDialog(user),
                        onDelete: () => _deleteUser(user),
                      ),
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
        backgroundColor: const Color(0xFF1E88E5),
        child: const Icon(Icons.person_add, color: Colors.white),
        elevation: 4,
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: const Color(0xFFF5F7FA),
      selectedColor: const Color(0xFF1E88E5).withOpacity(0.1),
      checkmarkColor: const Color(0xFF1E88E5),
      labelStyle: TextStyle(
        color: selected ? const Color(0xFF1E88E5) : const Color(0xFF1E293B),
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: BorderSide(
          color: selected 
              ? const Color(0xFF1E88E5) 
              : Colors.grey.withOpacity(0.3),
        ),
      ),
    );
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'étudiant':
        return '👨‍🎓 Étudiant';
      case 'enseignant':
        return '👨‍🏫 Enseignant';
      case 'admin':
        return '⚙️ Admin';
      default:
        return role;
    }
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
        return const Color(0xFF1E88E5);
      case 'enseignant':
        return const Color(0xFFFF9800);
      case 'admin':
        return const Color(0xFFE53935);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec nom et actions
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar avec initiale
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _getRoleColor(user.role),
                        _getRoleColor(user.role).withBlue(
                          _getRoleColor(user.role).blue - 20,
                        ),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      user.displayName[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Nom et rôle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getRoleColor(user.role).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getRoleLabel(user.role),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _getRoleColor(user.role),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Menu d'actions
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit();
                      } else if (value == 'delete') {
                        onDelete();
                      }
                    },
                    icon: const Icon(Icons.more_vert, 
                      color: Color(0xFF1E293B), 
                      size: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18, color: Color(0xFF1E88E5)),
                            SizedBox(width: 8),
                            Text('Modifier'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Color(0xFFE53935)),
                            SizedBox(width: 8),
                            Text('Supprimer',
                                style: TextStyle(color: Color(0xFFE53935))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            const Divider(height: 1, color: Colors.grey),
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
                    value: user.filiere ?? 'Non spécifié',
                  ),
                  const SizedBox(height: 8),
                  _DetailRow(
                    icon: Icons.grade,
                    label: 'Niveau',
                    value: user.niveau ?? 'Non spécifié',
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
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: const TextStyle(
            fontWeight: FontWeight.w600, 
            fontSize: 13,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.grey.shade600, 
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}