import 'package:flutter/material.dart';
import '../models/announcement.dart';

class AnnouncementFormDialog extends StatefulWidget {
  final Announcement? announcement;
  final String currentAuthor;
  final Function(Announcement) onSubmit;

  const AnnouncementFormDialog({
    super.key,
    this.announcement,
    required this.currentAuthor,
    required this.onSubmit,
  });

  @override
  State<AnnouncementFormDialog> createState() =>
      _AnnouncementFormDialogState();
}

class _AnnouncementFormDialogState extends State<AnnouncementFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _messageController;

  String _selectedType = 'général';
  bool _isPinned = false;
  List<String> _selectedRoles = ['tous'];
  List<String> _selectedFilieres = ['tous'];
  List<String> _selectedNiveaux = ['tous'];

  final List<String> _types = [
    'urgent',
    'académique',
    'administratif',
    'événement',
    'général',
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
  void initState() {
    super.initState();
    final a = widget.announcement;
    _titleController = TextEditingController(text: a?.title ?? '');
    _messageController = TextEditingController(text: a?.message ?? '');
    _selectedType = a?.type ?? 'général';
    _isPinned = a?.isPinned ?? false;
    _selectedRoles = a?.targetRoles ?? ['tous'];
    _selectedFilieres = a?.targetFilieres ?? ['tous'];
    _selectedNiveaux = a?.targetNiveaux ?? ['tous'];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  bool get _isStudentTarget => _selectedRoles.contains('étudiant');

  void _toggleRole(String role, bool selected) {
    setState(() {
      if (role == 'tous' && selected) {
        _selectedRoles = ['tous'];
        _selectedFilieres = ['tous'];
        _selectedNiveaux = ['tous'];
        return;
      }

      if (role != 'tous' && selected) {
        _selectedRoles.remove('tous');
        if (!_selectedRoles.contains(role)) {
          _selectedRoles.add(role);
        }
      }

      if (!selected) {
        _selectedRoles.remove(role);
      }

      if (_selectedRoles.isEmpty) {
        _selectedRoles = ['tous'];
      }

      if (!_selectedRoles.contains('étudiant')) {
        _selectedFilieres = ['tous'];
        _selectedNiveaux = ['tous'];
      }
    });
  }

  void _toggleFiliere(String filiere, bool selected) {
    setState(() {
      if (filiere == 'tous' && selected) {
        _selectedFilieres = ['tous'];
        return;
      }

      if (filiere != 'tous' && selected) {
        _selectedFilieres.remove('tous');
        if (!_selectedFilieres.contains(filiere)) {
          _selectedFilieres.add(filiere);
        }
      }

      if (!selected) {
        _selectedFilieres.remove(filiere);
      }

      if (_selectedFilieres.isEmpty) {
        _selectedFilieres = ['tous'];
      }
    });
  }

  void _toggleNiveau(String niveau, bool selected) {
    setState(() {
      if (niveau == 'tous' && selected) {
        _selectedNiveaux = ['tous'];
        return;
      }

      if (niveau != 'tous' && selected) {
        _selectedNiveaux.remove('tous');
        if (!_selectedNiveaux.contains(niveau)) {
          _selectedNiveaux.add(niveau);
        }
      }

      if (!selected) {
        _selectedNiveaux.remove(niveau);
      }

      if (_selectedNiveaux.isEmpty) {
        _selectedNiveaux = ['tous'];
      }
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final isEditing = widget.announcement != null;

    final announcement = Announcement(
      id: widget.announcement?.id ?? '',
      title: _titleController.text.trim(),
      message: _messageController.text.trim(),
      author: widget.currentAuthor,
      createdAt: widget.announcement?.createdAt ?? DateTime.now(),
      updatedAt: isEditing ? DateTime.now() : null,
      type: _selectedType,
      isPinned: _isPinned,
      targetRoles: _selectedRoles,
      targetFilieres: _isStudentTarget ? _selectedFilieres : ['tous'],
      targetNiveaux: _isStudentTarget ? _selectedNiveaux : ['tous'],
      isActive: widget.announcement?.isActive ?? true,
    );

    widget.onSubmit(announcement);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.announcement != null;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 650),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.campaign,
                        color: Color(0xFFFB8C00),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isEditing ? 'Modifier une annonce' : 'Nouvelle annonce',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _titleController,
                  decoration: _inputDecoration('Titre', Icons.title),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le titre est obligatoire';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _messageController,
                  maxLines: 5,
                  decoration: _inputDecoration('Message', Icons.notes),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le message est obligatoire';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: _inputDecoration('Type', Icons.category),
                  items: _types
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedType = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Public cible',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _roleChip('tous', 'Tous'),
                    _roleChip('étudiant', 'Étudiants'),
                    _roleChip('enseignant', 'Enseignants'),
                  ],
                ),
                if (_isStudentTarget) ...[
                  const SizedBox(height: 18),
                  const Text(
                    'Filières ciblées',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _filiereChip('tous', 'Toutes'),
                      ..._filieres.map((f) => _filiereChip(f, f)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Niveaux ciblés',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _niveauChip('tous', 'Tous'),
                      ..._niveaux.map((n) => _niveauChip(n, n)),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Épingler cette annonce',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Les annonces importantes restent en haut de la liste',
                  ),
                  value: _isPinned,
                  activeColor: const Color(0xFFFB8C00),
                  onChanged: (value) {
                    setState(() => _isPinned = value);
                  },
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Annuler'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E88E5),
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(52),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(isEditing ? 'Enregistrer' : 'Publier'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleChip(String value, String label) {
    final isSelected = _selectedRoles.contains(value);

    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (selected) => _toggleRole(value, selected),
      selectedColor: const Color(0xFF1E88E5).withOpacity(0.18),
      checkmarkColor: const Color(0xFF1E88E5),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF1E88E5) : const Color(0xFF334155),
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    );
  }

  Widget _filiereChip(String value, String label) {
    final isSelected = _selectedFilieres.contains(value);

    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (selected) => _toggleFiliere(value, selected),
      selectedColor: const Color(0xFF1E88E5).withOpacity(0.18),
      checkmarkColor: const Color(0xFF1E88E5),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF1E88E5) : const Color(0xFF334155),
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    );
  }

  Widget _niveauChip(String value, String label) {
    final isSelected = _selectedNiveaux.contains(value);

    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (selected) => _toggleNiveau(value, selected),
      selectedColor: const Color(0xFF8E24AA).withOpacity(0.18),
      checkmarkColor: const Color(0xFF8E24AA),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF8E24AA) : const Color(0xFF334155),
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 1.5),
      ),
    );
  }
}