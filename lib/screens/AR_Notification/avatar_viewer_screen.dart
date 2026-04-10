import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../../models/user_model.dart';

class AvatarViewerScreen extends StatelessWidget {
  final UserModel user;

  const AvatarViewerScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    const String avatarUrl =
        'https://models.readyplayer.me/6385a5099666c0d04dc147f4.glb';

    return Scaffold(
      appBar: AppBar(title: const Text('Mon Identite Metaverse')),
      body: Stack(
        children: [
          ModelViewer(
            src: avatarUrl,
            alt: 'Mon avatar 3D',
            ar: true,
            autoRotate: true,
            cameraControls: true,
            backgroundColor: const Color(0xFFF5F7FA),
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      user.displayName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('Etudiant certifie - Smart Campus'),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.view_in_ar),
                      label: const Text('INVOQUER MON AVATAR EN RA'),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
