import 'package:flutter/material.dart';
import '../models/room_model.dart';

class RoomFormDialog extends StatefulWidget {
  final RoomModel? initialRoom;
  final List<String> buildings;
  final Function(RoomModel) onSave;

  const RoomFormDialog({
    super.key,
    this.initialRoom,
    required this.buildings,
    required this.onSave,
  });

  @override
  State<RoomFormDialog> createState() => _RoomFormDialogState();
}

class _RoomFormDialogState extends State<RoomFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _floorController;
  late TextEditingController _capacityController;
  late TextEditingController _descriptionController;
  late String _selectedBuilding;
  List<String> _selectedEquipment = [];
  bool _isAvailable = true;

  final List<String> _availableEquipment = [
    'Projecteur',
    'Ordinateur',
    'Connexion Wi-Fi',
    'Tableau blanc',
    'Système audio',
    'Climatisation',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialRoom?.name ?? '');
    _floorController = TextEditingController(text: widget.initialRoom?.floor.toString() ?? '');
    _capacityController = TextEditingController(text: widget.initialRoom?.capacity.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.initialRoom?.description ?? '');
    _selectedBuilding = widget.initialRoom?.building ?? (widget.buildings.isNotEmpty ? widget.buildings.first : '');
    _selectedEquipment = List.from(widget.initialRoom?.equipment ?? []);
    _isAvailable = widget.initialRoom?.isAvailable ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _floorController.dispose();
    _capacityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Container(
        width: 500,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre
                Text(
                  widget.initialRoom == null
                      ? 'Ajouter une salle'
                      : 'Modifier la salle',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 24),

                // Contenu défilable
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Nom
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Nom de la salle',
                            prefixIcon: const Icon(Icons.meeting_room),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ce champ est requis';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Bâtiment
                        DropdownButtonFormField<String>(
                          value: _selectedBuilding.isNotEmpty ? _selectedBuilding : null,
                          decoration: InputDecoration(
                            labelText: 'Bâtiment',
                            prefixIcon: const Icon(Icons.location_city),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: widget.buildings.map((building) {
                            return DropdownMenuItem(
                              value: building,
                              child: Text(building),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedBuilding = value ?? '';
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez sélectionner un bâtiment';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Étage
                        TextFormField(
                          controller: _floorController,
                          decoration: InputDecoration(
                            labelText: 'Étage',
                            prefixIcon: const Icon(Icons.stairs),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ce champ est requis';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Veuillez entrer un nombre valide';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Capacité
                        TextFormField(
                          controller: _capacityController,
                          decoration: InputDecoration(
                            labelText: 'Capacité (personnes)',
                            prefixIcon: const Icon(Icons.people),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ce champ est requis';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Veuillez entrer un nombre valide';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Description
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            prefixIcon: const Icon(Icons.description),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),

                        // Équipements
                        const Text(
                          'Équipements',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: _availableEquipment.map((equipment) {
                            final isSelected = _selectedEquipment.contains(equipment);
                            return FilterChip(
                              label: Text(equipment),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedEquipment.add(equipment);
                                  } else {
                                    _selectedEquipment.remove(equipment);
                                  }
                                });
                              },
                              backgroundColor: const Color(0xFFF5F7FA),
                              selectedColor: const Color(0xFF1E88E5).withOpacity(0.1),
                              checkmarkColor: const Color(0xFF1E88E5),
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? const Color(0xFF1E88E5)
                                    : const Color(0xFF1E293B),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),

                        // Disponibilité
                        SwitchListTile(
                          title: const Text(
                            'Disponible',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          value: _isAvailable,
                          onChanged: (value) {
                            setState(() {
                              _isAvailable = value;
                            });
                          },
                          activeColor: const Color(0xFF1E88E5),
                          contentPadding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 16), // Espace avant les boutons
                      ],
                    ),
                  ),
                ),

                // Boutons (fixes en bas avec largeur limitée)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF1E293B),
                      ),
                      child: const Text('Annuler'),
                    ),
                    const SizedBox(width: 16),
                    // Le bouton est maintenant dans une colonne avec largeur limitée
                    SizedBox(
                      width: 100, // Largeur fixe pour éviter l'infini
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final room = RoomModel(
                              id: widget.initialRoom?.id ?? '',
                              name: _nameController.text,
                              building: _selectedBuilding,
                              floor: int.parse(_floorController.text),
                              capacity: int.parse(_capacityController.text),
                              equipment: _selectedEquipment,
                              description: _descriptionController.text,
                              isAvailable: _isAvailable,
                              createdAt: widget.initialRoom?.createdAt ?? DateTime.now(),
                              updatedAt: DateTime.now(),
                            );
                            widget.onSave(room);
                            Navigator.pop(context);
                          }
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
                        child: Text(
                          widget.initialRoom == null ? 'Ajouter' : 'Modifier',
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
    );
  }
}