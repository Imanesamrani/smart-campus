import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/room_controller.dart';
import '../../models/room_model.dart';
import 'unity_bridge_service.dart';

class CampusDigitalTwinScreen extends StatefulWidget {
  const CampusDigitalTwinScreen({super.key});

  @override
  State<CampusDigitalTwinScreen> createState() =>
      _CampusDigitalTwinScreenState();
}

class _CampusDigitalTwinScreenState extends State<CampusDigitalTwinScreen>
    with WidgetsBindingObserver {
  UnityBridgeAvailability _availability = UnityBridgeAvailability.unavailable;
  bool _isLaunchingUnity = false;
  bool _waitingForUnityReturn = false;
  DateTime? _launchBlockedUntil;
  String? _selectedBuilding;
  RoomModel? _selectedRoom;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final roomController = context.read<RoomController>();
      if (roomController.rooms.isEmpty) {
        await roomController.loadRooms();
      }
      await _checkUnityAvailability();
      _hydrateDefaultSelection(roomController.rooms);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _waitingForUnityReturn) {
      _waitingForUnityReturn = false;
      _launchBlockedUntil = DateTime.now().add(const Duration(seconds: 5));

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).maybePop();
      });
    }
  }

  bool get _isLaunchTemporarilyBlocked {
    final blockedUntil = _launchBlockedUntil;
    if (blockedUntil == null) return false;
    return DateTime.now().isBefore(blockedUntil);
  }

  Future<void> _checkUnityAvailability() async {
    final availability = await UnityBridgeService.checkAvailability();
    if (!mounted) return;

    setState(() {
      _availability = availability;
    });
  }

  void _hydrateDefaultSelection(List<RoomModel> rooms) {
    if (rooms.isEmpty || _selectedBuilding != null) return;

    final buildings = rooms
        .map((room) => room.building)
        .where((name) => name.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    if (buildings.isEmpty) return;

    setState(() {
      _selectedBuilding = buildings.first;
      _selectedRoom = rooms.cast<RoomModel?>().firstWhere(
        (room) => room?.building == buildings.first,
        orElse: () => null,
      );
    });
  }

  Future<void> _launchUnityCampus() async {
    if (_isLaunchTemporarilyBlocked || _isLaunchingUnity) return;

    setState(() => _isLaunchingUnity = true);

    try {
      final launched = await UnityBridgeService.launchCampus(
        focusBuilding: _selectedBuilding,
        focusRoom: _selectedRoom?.name,
      );

      if (!mounted) return;

      setState(() => _isLaunchingUnity = false);

      if (launched) {
        _waitingForUnityReturn = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ouverture du metaverse Unity...')),
        );
        return;
      }

      _showUnitySetupSheet();
    } catch (e) {
      debugPrint('[Campus3D] Error launching Unity: $e');
      if (!mounted) return;
      setState(() => _isLaunchingUnity = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du lancement: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showUnitySetupSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ouverture Unity indisponible',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text(
                _availability == UnityBridgeAvailability.available
                    ? 'Le bridge Android est detecte, mais Unity ne s est pas ouvert correctement. Verifiez que le dernier export Unity a bien ete copie dans le projet Android.'
                    : 'Le module Unity n est pas detecte dans cette build. Verifiez la presence de unityLibrary/shared ou relancez une build Android avec le module exporte.',
                style: const TextStyle(
                  height: 1.5,
                  color: Color(0xFF4B5563),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Etat actuel :',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text('- Ecran metaverse Flutter pret'),
              const Text('- Selection batiment / salle prete'),
              Text(
                _availability == UnityBridgeAvailability.available
                    ? '- Bridge Flutter -> Android -> Unity detecte'
                    : '- Module Unity non detecte dans cette build',
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Compris'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Metaverse ENSIASD'),
        backgroundColor: const Color(0xFF123B63),
      ),
      body: Consumer<RoomController>(
        builder: (context, controller, child) {
          final rooms = controller.rooms;
          final buildings = rooms
              .map((room) => room.building)
              .where((name) => name.trim().isNotEmpty)
              .toSet()
              .toList()
            ..sort();

          final filteredRooms = _selectedBuilding == null
              ? rooms
              : rooms.where((room) => room.building == _selectedBuilding).toList();

          return RefreshIndicator(
            onRefresh: () async {
              await controller.loadRooms();
              await _checkUnityAvailability();
            },
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildHeroCard(),
                const SizedBox(height: 18),
                _buildBuildingSelector(buildings),
                const SizedBox(height: 18),
                _buildRoomFocusCard(filteredRooms),
                const SizedBox(height: 18),
                _buildLiveRoomStatus(filteredRooms),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF123B63), Color(0xFF2E7CC2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF123B63).withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'ENSIASD - Taroudant',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Campus immersif 3D',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Explorez le campus, ciblez un batiment ou une salle, puis lancez la scene Unity du metaverse directement depuis l application.',
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (_isLaunchingUnity || _isLaunchTemporarilyBlocked)
                  ? null
                  : _launchUnityCampus,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF123B63),
              ),
              icon: _isLaunchingUnity
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.view_in_ar_outlined),
              label: Text(
                _isLaunchingUnity
                    ? 'Ouverture...'
                    : _isLaunchTemporarilyBlocked
                        ? 'Retour vers l app...'
                        : 'Ouvrir le campus Unity',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuildingSelector(List<String> buildings) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE4ECF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Destination campus',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choisissez la zone a mettre en avant dans le metaverse Unity.',
            style: TextStyle(color: Color(0xFF4B5563)),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: buildings.map((building) {
              final selected = building == _selectedBuilding;
              return ChoiceChip(
                label: Text(building),
                selected: selected,
                onSelected: (_) {
                  setState(() {
                    _selectedBuilding = building;
                    _selectedRoom = null;
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomFocusCard(List<RoomModel> filteredRooms) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE4ECF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Point de focus Unity',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: filteredRooms.any(
              (room) => room.name == _selectedRoom?.name,
            )
                ? _selectedRoom?.name
                : null,
            decoration: const InputDecoration(
              labelText: 'Salle a mettre en avant',
            ),
            items: filteredRooms
                .map(
                  (room) => DropdownMenuItem<String>(
                    value: room.name,
                    child: Text(room.name),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedRoom = filteredRooms.cast<RoomModel?>().firstWhere(
                  (room) => room?.name == value,
                  orElse: () => null,
                );
              });
            },
          ),
          const SizedBox(height: 12),
          Text(
            _selectedRoom == null
                ? 'Le campus Unity s ouvrira sur la zone selectionnee.'
                : 'Le focus Unity ciblera ${_selectedRoom!.name} dans ${_selectedRoom!.building}.',
            style: const TextStyle(color: Color(0xFF4B5563)),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveRoomStatus(List<RoomModel> rooms) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE4ECF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Etat des salles en temps reel',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Les donnees de salle restent visibles dans Flutter meme avant l ouverture du metaverse.',
            style: TextStyle(color: Color(0xFF4B5563)),
          ),
          const SizedBox(height: 14),
          if (rooms.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text('Aucune salle disponible pour cette zone.'),
              ),
            )
          else
            ...rooms.take(6).map(
              (room) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.circle,
                  size: 14,
                  color: room.isAvailable ? Colors.green : Colors.redAccent,
                ),
                title: Text(room.name),
                subtitle: Text('${room.building} - Etage ${room.floor}'),
                trailing: Text(
                  room.isAvailable ? 'Libre' : 'Occupee',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: room.isAvailable ? Colors.green : Colors.redAccent,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _selectedBuilding = room.building;
                    _selectedRoom = room;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }
}
