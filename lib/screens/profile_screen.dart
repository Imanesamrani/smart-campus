import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../controllers/auth_controller.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _displayNameController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = false;
  String? _selectedNiveau;
  
  final List<String> _niveaux = [
    '1ère année',
    '2ème année',
    '3ème année',
  ];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthController>().currentUser;
    if (user != null) {
      _displayNameController.text = user.displayName;
      _selectedNiveau = user.niveau;
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_displayNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer votre nom'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final authController = context.read<AuthController>();
    final authService = AuthService();
    final user = authController.currentUser;

    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      // Préparer les données de mise à jour
      Map<String, dynamic> updateData = {
        'displayName': _displayNameController.text.trim(),
      };

      // Ajouter le niveau si c'est un étudiant
      if (user.role == 'étudiant' && _selectedNiveau != null) {
        updateData['niveau'] = _selectedNiveau;
      }

      // Mettre à jour dans Firestore
      await authService.updateUserProfile(user.uid, updateData);

      // Mettre à jour le nom localement (Firebase Auth)
      await authService.updateDisplayName(_displayNameController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Photo de profil
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.blue.shade100,
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : (user.photoURL != null
                                ? NetworkImage(user.photoURL!)
                                : null) as ImageProvider?,
                        child: (_selectedImage == null && user.photoURL == null)
                            ? Text(
                                user.displayName[0].toUpperCase(),
                                style: TextStyle(
                                  fontSize: 40,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue[800],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Informations utilisateur
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Rôle
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              user.role == 'étudiant'
                                  ? '👨‍🎓 Étudiant'
                                  : (user.role == 'enseignant'
                                      ? '👨‍🏫 Enseignant'
                                      : '👨‍💼 Administrateur'),
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Email
                          Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Filière (si étudiant)
                          if (user.role == 'étudiant' && user.filiere != null) ...[
                            Text(
                              'Filière',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                border: Border.all(
                                  color: Colors.green[300]!,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                user.filiere!,
                                style: TextStyle(
                                  color: Colors.green[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Créé le
                          Text(
                            'Membre depuis',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Formulaire de modification
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Modifier mon profil',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Nom
                          TextFormField(
                            controller: _displayNameController,
                            decoration: InputDecoration(
                              labelText: 'Nom complet',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Niveau (si étudiant)
                          if (user.role == 'étudiant') ...[
                            DropdownButtonFormField<String>(
                              value: _selectedNiveau,
                              decoration: InputDecoration(
                                labelText: 'Niveau scolaire',
                                prefixIcon: const Icon(Icons.trending_up_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              items: _niveaux.map((niveau) {
                                return DropdownMenuItem(
                                  value: niveau,
                                  child: Text(niveau),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedNiveau = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Boutons
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _updateProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      'Enregistrer les modifications',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 50,
                            child: OutlinedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blue,
                                side: BorderSide(
                                  color: Colors.blue,
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Annuler',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
