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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8FBFF),
              Color(0xFFF0F5FF),
              Color(0xFFE8F0FF),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Back Button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  // Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF0066CC),
                          Color(0xFF0052A3),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0066CC).withOpacity(0.25),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1_rounded,
                      size: 45,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Titre
                  Text(
                    'Créer un compte',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: const Color(0xFF1A1A1A),
                          fontWeight: FontWeight.w700,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  
                  // Subtitle
                  Text(
                    'Rejoignez la communauté Smart Campus',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF666666),
                          fontWeight: FontWeight.w400,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Card avec formulaire
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0066CC).withOpacity(0.12),
                          blurRadius: 24,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Nom complet
                          TextFormField(
                            controller: _displayNameController,
                            decoration: InputDecoration(
                              labelText: 'Nom complet',
                              hintText: 'Jean Dupont',
                              prefixIcon: const Icon(Icons.person_outline_rounded),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer votre nom';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Email
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Adresse Email',
                              hintText: 'votre@email.com',
                              prefixIcon: const Icon(Icons.mail_outline_rounded),
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
                          const SizedBox(height: 20),

                          // Rôle
                          DropdownButtonFormField<String>(
                            initialValue: _selectedRole,
                            decoration: InputDecoration(
                              labelText: 'Rôle',
                              prefixIcon: const Icon(Icons.badge_outlined),
                            ),
                            items: _roles.map((role) {
                              return DropdownMenuItem(
                                value: role,
                                child: Row(
                                  children: [
                                    Icon(
                                      role == 'étudiant'
                                          ? Icons.school
                                          : role == 'enseignant'
                                              ? Icons.person_4
                                              : Icons.admin_panel_settings,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      role == 'étudiant'
                                          ? 'Étudiant'
                                          : role == 'enseignant'
                                              ? 'Enseignant'
                                              : 'Admin',
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedRole = value!;
                                if (value != 'étudiant') {
                                  _selectedFiliere = null;
                                  _selectedNiveau = null;
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 20),

                          // Filière (seulement pour les étudiants)
                          if (_selectedRole == 'étudiant') ...[
                            DropdownButtonFormField<String>(
                              value: _selectedFiliere,
                              decoration: InputDecoration(
                                labelText: 'Filière',
                                prefixIcon: const Icon(Icons.school_rounded),
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Sélectionnez une filière';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            
                            // Niveau (seulement pour les étudiants)
                            DropdownButtonFormField<String>(
                              value: _selectedNiveau,
                              decoration: InputDecoration(
                                labelText: 'Niveau',
                                prefixIcon: const Icon(Icons.trending_up_rounded),
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Sélectionnez un niveau';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Mot de passe
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Mot de passe',
                              hintText: '••••••••',
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer un mot de passe';
                              }
                              if (value.length < 6) {
                                return 'Minimum 6 caractères';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Confirmer mot de passe
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            decoration: InputDecoration(
                              labelText: 'Confirmer le mot de passe',
                              hintText: '••••••••',
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                              ),
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
                          const SizedBox(height: 32),

                          // Register Button
                          Consumer<AuthController>(
                            builder: (context, authController, child) {
                              return ElevatedButton(
                                onPressed: authController.isLoading
                                    ? null
                                    : _handleRegister,
                                child: authController.isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Text('S\'INSCRIRE'),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Vous avez un compte ? ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF666666),
                            ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Se connecter',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF0066CC),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}