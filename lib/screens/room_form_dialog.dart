import 'package:flutter/material.dart';
import '../models/room_model.dart';

class RoomFormDialog extends StatefulWidget {
  final RoomModel? initialRoom;
  final Function(RoomModel) onSave;

  const RoomFormDialog({
    super.key,
    this.initialRoom,
    required this.onSave,
  });

  @override
  State<RoomFormDialog> createState() => _RoomFormDialogState();
}

class _RoomFormDialogState extends State<RoomFormDialog> {
  late TextEditingController _nameController;
  late TextEditingController _buildingController;
  late TextEditingController _floorController;
  late TextEditingController _capacityController;
  late TextEditingController _descriptionController;

  List<String> _selectedEquipment = [];

  final List<String> _availableEquipmentOptions = [
    'Projecteur',
    'Ordinateur',
    'Connexion Wi-Fi',
    'Tableau blanc',
    'Vidéoprojecteur',
    'Système audio',
    'Climatisation',
    'Tableau noir',
  ];

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    if (widget.initialRoom != null) {
      _nameController = TextEditingController(text: widget.initialRoom!.name);
      _buildingController =
          TextEditingController(text: widget.initialRoom!.building);
      _floorController =
          TextEditingController(text: widget.initialRoom!.floor.toString());
      _capacityController =
          TextEditingController(text: widget.initialRoom!.capacity.toString());
      _descriptionController =
          TextEditingController(text: widget.initialRoom!.description);
      _selectedEquipment = List.from(widget.initialRoom!.equipment);
    } else {
      _nameController = TextEditingController();
      _buildingController = TextEditingController();
      _floorController = TextEditingController();
      _capacityController = TextEditingController();
      _descriptionController = TextEditingController();
      _selectedEquipment = [];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _buildingController.dispose();
    _floorController.dispose();
    _capacityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _toggleEquipment(String equipment) {
    setState(() {
      if (_selectedEquipment.contains(equipment)) {
        _selectedEquipment.remove(equipment);
      } else {
        _selectedEquipment.add(equipment);
      }
    });
  }

  void _saveRoom() {
    // Validation
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Le nom de la salle est obligatoire')),
      );
      return;
    }

    if (_buildingController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Le bâtiment est obligatoire')),
      );
      return;
    }

    if (_floorController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ L\'étage est obligatoire')),
      );
      return;
    }

    if (_capacityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ La capacité est obligatoire')),
      );
      return;
    }

    final floor = int.tryParse(_floorController.text);
    final capacity = int.tryParse(_capacityController.text);

    if (floor == null || capacity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('⚠️ L\'étage et la capacité doivent être des nombres')),
      );
      return;
    }

    final newRoom = RoomModel(
      id: widget.initialRoom?.id ?? DateTime.now().toString(),
      name: _nameController.text.trim(),
      building: _buildingController.text.trim(),
      floor: floor,
      capacity: capacity,
      equipment: _selectedEquipment,
      description: _descriptionController.text.trim(),
      isAvailable: true,
      createdAt: widget.initialRoom?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onSave(newRoom);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initialRoom == null ? 'Ajouter une salle' : 'Modifier la salle',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      scrollable: true,
      contentPadding: const EdgeInsets.all(24),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📝 Nom de la salle
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nom de la salle *',
                hintText: 'Ex: Amphi 1, Salle 201',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.meeting_room),
              ),
            ),
            const SizedBox(height: 16),

            // 🏢 Bâtiment
            TextField(
              controller: _buildingController,
              decoration: InputDecoration(
                labelText: 'Bâtiment *',
                hintText: 'Ex: Bâtiment A, Bloc 2',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 16),

            // 📍 Étage et capacité (sur une seule ligne)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _floorController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Étage *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.layers),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _capacityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Capacité *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.people),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 📄 Description
            TextField(
              controller: _descriptionController,
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.description),
              ),
            ),
            const SizedBox(height: 20),

            // 🎛️ Équipements
            const Text(
              'Équipements disponibles',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableEquipmentOptions
                  .map((equipment) => FilterChip(
                        label: Text(equipment),
                        selected: _selectedEquipment.contains(equipment),
                        onSelected: (selected) => _toggleEquipment(equipment),
                        backgroundColor: Colors.grey.shade100,
                        selectedColor: Colors.blue.shade100,
                        labelStyle: TextStyle(
                          color: _selectedEquipment.contains(equipment)
                              ? Colors.blue.shade700
                              : Colors.grey.shade700,
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton.icon(
          onPressed: _saveRoom,
          icon: const Icon(Icons.save),
          label: Text(
              widget.initialRoom == null ? 'Ajouter' : 'Modifier'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
