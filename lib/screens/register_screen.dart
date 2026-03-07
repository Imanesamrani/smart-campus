import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _displayNameController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedRole = 'étudiant';
  String? _selectedFiliere;
  String? _selectedNiveau;
  
  final List<String> _roles = [
    'étudiant',
    'enseignant',
    'admin',
  ];
  
  final List<String> _filieres = [
    'MGSI',
    'IL',
    'SDBDIA',
    'SITCN',
  ];
  
  final List<String> _niveaux = [
    '1ère année',
    '2ème année',
    '3ème année',
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final authController = context.read<AuthController>();
      
      // Pour les étudiants, vérifier que filière et niveau sont sélectionnés
      if (_selectedRole == 'étudiant' && (_selectedFiliere == null || _selectedNiveau == null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner une filière et un niveau'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      bool success = await authController.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _displayNameController.text.trim(),
        role: _selectedRole,
        filiere: _selectedFiliere,
        niveau: _selectedNiveau,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inscription réussie ! Veuillez vous connecter.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else if (mounted && authController.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authController.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.blue.shade100,
              Colors.grey.shade100,
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shadowColor: Colors.blue.shade200,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Titre
                      const Text(
                        'Créer un compte',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rejoignez la communauté Smart Campus',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Nom complet
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre nom';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre email';
                          }
                          if (!value.contains('@')) {
                            return 'Email invalide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Rôle
                      DropdownButtonFormField<String>(
                        initialValue: _selectedRole,
                        decoration: InputDecoration(
                          labelText: 'Rôle',
                          prefixIcon: const Icon(Icons.badge_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        items: _roles.map((role) {
                          return DropdownMenuItem(
                            value: role,
                            child: Text(
                              role == 'étudiant' ? 'Étudiant' : (role == 'enseignant' ? 'Enseignant' : 'Admin'),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value!;
                            // Réinitialiser filière et niveau si le rôle change
                            if (value != 'étudiant') {
                              _selectedFiliere = null;
                              _selectedNiveau = null;
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Filière (seulement pour les étudiants)
                      if (_selectedRole == 'étudiant') ...
                        [
                          DropdownButtonFormField<String>(
                            value: _selectedFiliere,
                            decoration: InputDecoration(
                              labelText: 'Filière',
                              prefixIcon: const Icon(Icons.school_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            items: _filieres.map((filiere) {
                              return DropdownMenuItem(
                                value: filiere,
                                child: Text(filiere),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedFiliere = value;
                              });
                            },
                            validator: _selectedRole == 'étudiant'
                                ? (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Veuillez sélectionner une filière';
                                    }
                                    return null;
                                  }
                                : null,
                          ),
                          const SizedBox(height: 16),
                          
                          // Niveau (seulement pour les étudiants)
                          DropdownButtonFormField<String>(
                            value: _selectedNiveau,
                            decoration: InputDecoration(
                              labelText: 'Niveau',
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
                            validator: _selectedRole == 'étudiant'
                                ? (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Veuillez sélectionner un niveau';
                                    }
                                    return null;
                                  }
                                : null,
                          ),
                          const SizedBox(height: 16),
                        ],

                      // Mot de passe
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un mot de passe';
                          }
                          if (value.length < 6) {
                            return 'Le mot de passe doit contenir au moins 6 caractères';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Confirmation mot de passe
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirmer le mot de passe',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez confirmer votre mot de passe';
                          }
                          if (value != _passwordController.text) {
                            return 'Les mots de passe ne correspondent pas';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Conditions d'utilisation
                      Row(
                        children: [
                          Checkbox(
                            value: true,
                            onChanged: (value) {},
                          ),
                          Expanded(
                            child: Text(
                              'J\'accepte les conditions d\'utilisation et la politique de confidentialité',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Bouton d'inscription
                      Consumer<AuthController>(
                        builder: (context, authController, child) {
                          return SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: authController.isLoading
                                  ? null
                                  : _handleRegister,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[800],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: authController.isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      'S\'INSCRIRE',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Lien vers connexion
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Déjà un compte ? Se connecter',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}