import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserFormDialog extends StatefulWidget {
  final UserModel? initialUser;
  final Function(Map<String, dynamic>) onSave;
  final bool isNewUser;

  const UserFormDialog({
    super.key,
    this.initialUser,
    required this.onSave,
    this.isNewUser = true,
  });

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _displayNameController;
  
  String _selectedRole = 'étudiant';
  String? _selectedFiliere;
  String? _selectedNiveau;

  final List<String> _roles = ['étudiant', 'enseignant', 'admin'];
  final List<String> _filieres = ['MGSI', 'IL', 'SDBDIA', 'SITCN'];
  final List<String> _niveaux = ['1ère année', '2ème année', '3ème année'];

  @override
  void initState() {
    super.initState();
    if (widget.initialUser != null) {
      _emailController = TextEditingController(text: widget.initialUser!.email);
      _passwordController = TextEditingController();
      _displayNameController =
          TextEditingController(text: widget.initialUser!.displayName);
      _selectedRole = widget.initialUser!.role;
      _selectedFiliere = widget.initialUser!.filiere;
      _selectedNiveau = widget.initialUser!.niveau;
    } else {
      _emailController = TextEditingController();
      _passwordController = TextEditingController();
      _displayNameController = TextEditingController();
      _selectedRole = 'étudiant';
      _selectedFiliere = null;
      _selectedNiveau = null;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  void _saveUser() {
    // Validations
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ L\'email est obligatoire')),
      );
      return;
    }

    if (_displayNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Le nom d\'affichage est obligatoire')),
      );
      return;
    }

    // Pour un nouvel utilisateur, le mot de passe est obligatoire
    if (widget.isNewUser && _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('⚠️ Le mot de passe est obligatoire pour un nouvel utilisateur')),
      );
      return;
    }

    // Pour les étudiants, filière et niveau sont obligatoires
    if (_selectedRole == 'étudiant' &&
        (_selectedFiliere == null || _selectedNiveau == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('⚠️ Filière et niveau sont obligatoires pour les étudiants')),
      );
      return;
    }

    final userData = {
      'email': _emailController.text.trim(),
      'displayName': _displayNameController.text.trim(),
      'role': _selectedRole,
      if (widget.isNewUser) 'password': _passwordController.text,
      if (_selectedRole == 'étudiant') 'filiere': _selectedFiliere,
      if (_selectedRole == 'étudiant') 'niveau': _selectedNiveau,
    };

    widget.onSave(userData);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.isNewUser ? 'Ajouter un utilisateur' : 'Modifier l\'utilisateur',
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      scrollable: true,
      contentPadding: const EdgeInsets.all(24),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📧 Email
            TextField(
              controller: _emailController,
              enabled: widget.isNewUser, // Email non modifiable pour les utilisateurs existants
              decoration: InputDecoration(
                labelText: 'Email *',
                hintText: 'utilisateur@example.com',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // 📝 Nom d'affichage
            TextField(
              controller: _displayNameController,
              decoration: InputDecoration(
                labelText: 'Nom d\'affichage *',
                hintText: 'Jean Dupont',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),

            // 🔐 Mot de passe (seulement pour les nouveaux utilisateurs)
            if (widget.isNewUser) ...[
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Mot de passe *',
                  hintText: 'Entrez un mot de passe sécurisé',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
            ],

            // 👥 Rôle
            const Text(
              'Rôle *',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              items: _roles.map((role) {
                String roleLabel = role;
                if (role == 'étudiant') roleLabel = '👨‍🎓 Étudiant';
                if (role == 'enseignant') roleLabel = '👨‍🏫 Enseignant';
                if (role == 'admin') roleLabel = '⚙️ Administrateur';

                return DropdownMenuItem(
                  value: role,
                  child: Text(roleLabel),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedRole = value!);
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),

            // 📚 Filière (seulement pour étudiants)
            if (_selectedRole == 'étudiant') ...[
              const Text(
                'Filière *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedFiliere,
                isExpanded: true,
                items: _filieres.map((filiere) {
                  return DropdownMenuItem(
                    value: filiere,
                    child: Text(filiere),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedFiliere = value);
                },
                decoration: InputDecoration(
                  hintText: 'Sélectionnez une filière',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),

              // 📍 Niveau (seulement pour étudiants)
              const Text(
                'Niveau *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedNiveau,
                isExpanded: true,
                items: _niveaux.map((niveau) {
                  return DropdownMenuItem(
                    value: niveau,
                    child: Text(niveau),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedNiveau = value);
                },
                decoration: InputDecoration(
                  hintText: 'Sélectionnez un niveau',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton.icon(
          onPressed: _saveUser,
          icon: const Icon(Icons.check),
          label: Text(widget.isNewUser ? 'Créer' : 'Modifier'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        ),
      ],
    );
  }
}
