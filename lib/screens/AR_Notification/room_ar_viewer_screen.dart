import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/room_model.dart';

class RoomARViewerScreen extends StatefulWidget {
  final RoomModel room;

  const RoomARViewerScreen({super.key, required this.room});

  @override
  State<RoomARViewerScreen> createState() => _RoomARViewerScreenState();
}

class _RoomARViewerScreenState extends State<RoomARViewerScreen> {
  late String _currentModelUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Retour au modèle stable de l'astronaute
    _currentModelUrl = widget.room.model3DUrl ??
        'https://modelviewer.dev/shared-assets/models/Astronaut.glb';

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          ModelViewer(
            key: ValueKey(_currentModelUrl),
            src: _currentModelUrl,
            alt: "Modèle 3D de la salle ${widget.room.name}",
            ar: true, 
            autoRotate: true,
            cameraControls: true,
            backgroundColor: const Color(0xFFF5F7FA),
            loading: Loading.eager,
          ),

          if (_isLoading)
            Container(
              color: const Color(0xFFF5F7FA),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF1E88E5)),
                    SizedBox(height: 20),
                    Text(
                      'Chargement du modèle 3D...',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBackButton(context),
                _buildARButton(context),
              ],
            ),
          ),

          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: _buildInfoCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildARButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _launchAR(context, _currentModelUrl),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E88E5),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E88E5).withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          children: [
            Icon(Icons.view_in_ar, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text(
              'VOIR EN AR',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.room.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      '${widget.room.building} • Étage ${widget.room.floor}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.meeting_room, color: Colors.blue),
              ),
            ],
          ),
          const Divider(height: 30),
          const Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: Colors.orange),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Explorez le modèle ou utilisez le bouton en haut pour la projection RA.',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _launchAR(BuildContext context, String modelUrl) async {
    final Uri arUri = Uri.parse(
        'intent://arvr.google.com/scene-viewer/1.0'
            '?file=$modelUrl'
            '&mode=ar_only'
            '#Intent;scheme=https;package=com.google.android.googlequicksearchbox;action=android.intent.action.VIEW;end;'
    );

    try {
      if (await canLaunchUrl(arUri)) {
        await launchUrl(arUri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Le mode RA réel n\'est pas supporté sur cet appareil.')),
          );
        }
      }
    } catch (e) {
      debugPrint('Erreur AR: $e');
    }
  }
}
