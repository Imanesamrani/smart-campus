import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/map_controller.dart';
import '../models/building.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CampusMapController>().loadBuildings();
    });
  }

  Future<void> _openDirections(Building building) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${building.latitude},${building.longitude}',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Impossible d'ouvrir l'itinéraire."),
        ),
      );
    }
  }

  void _showBuildingInfo(Building building) {
  final servicesText = building.services.isEmpty
      ? 'Aucun service'
      : building.services.join(', ');

  final openingHoursText = building.openingHours.isEmpty
      ? 'Non renseigné'
      : building.openingHours.entries
          .map((entry) => '${entry.key} : ${entry.value}')
          .join('\n');

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(building.name),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Code : ${building.code}'),
            Text('Adresse : ${building.address}'),
            Text('Étages : ${building.floors}'),
            const SizedBox(height: 8),
            Text('Description : ${building.description}'),
            const SizedBox(height: 12),
            const Text(
              'Services :',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(servicesText),
            const SizedBox(height: 12),
            const Text(
              "Heures d'ouverture :",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(openingHoursText),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fermer'),
        ),
        ElevatedButton(
          onPressed: () => _openDirections(building),
          child: const Text('Itinéraire'),
        ),
      ],
    ),
  );
}
       

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CampusMapController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte du campus'),
        centerTitle: true,
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : controller.errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      controller.errorMessage!,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : controller.buildings.isEmpty
                  ? const Center(
                      child: Text('Aucun bâtiment trouvé dans Firestore'),
                    )
                  : FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(
                          controller.buildings.first.latitude,
                          controller.buildings.first.longitude,
                        ),
                        initialZoom: 16,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName:
                              'com.example.flutter_smart_campus',
                        ),
                        MarkerLayer(
                          markers: controller.buildings.map((building) {
                            return Marker(
                              point:
                                  LatLng(building.latitude, building.longitude),
                              width: 120,
                              height: 80,
                              child: GestureDetector(
                                onTap: () => _showBuildingInfo(building),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Colors.red,
                                      size: 38,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: const [
                                          BoxShadow(
                                            blurRadius: 3,
                                            color: Colors.black26,
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        building.name,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
    );
  }
}