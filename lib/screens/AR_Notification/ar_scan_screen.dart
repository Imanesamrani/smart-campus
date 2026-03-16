import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:provider/provider.dart';
import '../../controllers/room_controller.dart';
import '../../models/room_model.dart';
import '../room_details_screen.dart';

class ArScanScreen extends StatefulWidget {
  const ArScanScreen({super.key});

  @override
  State<ArScanScreen> createState() => _ArScanScreenState();
}

class _ArScanScreenState extends State<ArScanScreen> {
  CameraController? _cameraController;
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  bool _isBusy = false;
  bool _isCameraInitialized = false;
  bool _canProcess = true;
  RoomModel? _detectedRoom;
  String? _unrecognizedText;
  final DraggableScrollableController _sheetController = DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoomController>().loadRooms();
    });
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _cameraController = CameraController(
      cameras[0],
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21,
    );

    try {
      await _cameraController!.initialize();
      if (!mounted) return;
      setState(() {
        _isCameraInitialized = true;
      });
      _cameraController!.startImageStream(_processCameraImage);
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  void _processCameraImage(CameraImage image) async {
    if (_isBusy || !_canProcess) return;
    _isBusy = true;

    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) return;

      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      if (mounted) {
        _analyzeText(recognizedText.text);
      }
    } catch (e) {
      debugPrint('Error processing image: $e');
    } finally {
      _isBusy = false;
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final sensorOrientation = _cameraController!.description.sensorOrientation;
    InputImageRotation? rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    if (rotation == null) return null;
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;
    final plane = image.planes.first;
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  String _normalize(String text) {
    return text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '').trim();
  }

  void _analyzeText(String text) {
    if (text.trim().isEmpty) return;
    final rooms = context.read<RoomController>().rooms;
    final cleanOcr = _normalize(text);
    RoomModel? found;

    for (final room in rooms) {
      final cleanName = _normalize(room.name);
      if (cleanName.isNotEmpty && (cleanOcr.contains(cleanName) || cleanName.contains(cleanOcr))) {
        found = room;
        break;
      }
    }

    if (found != null) {
      if (_detectedRoom?.id != found.id) {
        setState(() {
          _detectedRoom = found;
          _unrecognizedText = null;
        });
        _sheetController.animateTo(0.35, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    } else {
      final RegExp roomPattern = RegExp(r'(salle|amphi|bureau|labo|bloc|s\.|a\.)\s*(\w+)', caseSensitive: false);
      final match = roomPattern.firstMatch(text.toLowerCase());
      if (match != null && _detectedRoom == null) {
        final potential = match.group(0);
        if (potential != null && potential.length > 3 && _unrecognizedText != potential) {
          setState(() => _unrecognizedText = potential);
        }
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator(color: Colors.white)));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_cameraController!),
          
          if (_detectedRoom == null && _unrecognizedText == null) 
            _buildScannerOverlay(),

          Positioned(
            top: 50,
            left: 20,
            child: Container(
              decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          if (_detectedRoom != null)
            _buildDraggableRoomSheet(_detectedRoom!),
            
          if (_detectedRoom == null && _unrecognizedText != null)
            _buildNotFoundCard(_unrecognizedText!),

          if (_detectedRoom == null && _unrecognizedText == null)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(30)),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                      SizedBox(width: 12),
                      Text('Analyse en cours...', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return Center(
      child: Container(
        width: 280,
        height: 180,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(child: Text("Visez le nom de la salle", style: TextStyle(color: Colors.white70))),
      ),
    );
  }

  Widget _buildDraggableRoomSheet(RoomModel room) {
    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      controller: _sheetController,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 5)],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(room.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                      Text('${room.building} • Étage ${room.floor}', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: Colors.grey),
                    onPressed: () => setState(() => _detectedRoom = null),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Center(child: Text('↑ Glissez pour voir plus d\'infos ↑', style: TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.w500))),
              const Divider(height: 30),
              
              // Infos supplémentaires révélées par le Swipe Up
              _buildExpandedInfo(Icons.people_outline, 'Capacité', '${room.capacity} personnes'),
              const SizedBox(height: 15),
              _buildExpandedInfo(
                room.isAvailable ? Icons.check_circle_outline : Icons.highlight_off,
                'Disponibilité',
                room.isAvailable ? 'Libre actuellement' : 'Occupée',
                color: room.isAvailable ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 25),
              const Text('Équipements disponibles', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: room.equipment.map((e) => Chip(
                  label: Text(e, style: const TextStyle(fontSize: 12)),
                  backgroundColor: Colors.blue[50],
                  side: BorderSide.none,
                )).toList(),
              ),
              const SizedBox(height: 25),
              const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text(room.description.isEmpty ? 'Aucune description disponible.' : room.description, style: TextStyle(color: Colors.grey[700], height: 1.4)),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RoomDetailsScreen(room: room))),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('ACCÉDER À TOUS LES DÉTAILS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExpandedInfo(IconData icon, String label, String value, {Color? color}) {
    return Row(
      children: [
        Icon(icon, color: color ?? Colors.blue, size: 28),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildNotFoundCard(String text) {
    return Positioned(
      bottom: 30,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 20)]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 50),
            const SizedBox(height: 16),
            const Text('Salle non répertoriée', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('"$text" n\'existe pas dans notre base de données.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 20),
            OutlinedButton(onPressed: () => setState(() => _unrecognizedText = null), child: const Text('RÉESSAYER')),
          ],
        ),
      ),
    );
  }
}
