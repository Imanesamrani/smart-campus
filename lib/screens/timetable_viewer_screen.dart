import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class TimetableViewerScreen extends StatelessWidget {
  final String timetableId;

  const TimetableViewerScreen({
    super.key,
    required this.timetableId,
  });

  Future<void> _openPdf(String url) async {
    final uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Impossible d’ouvrir le fichier PDF');
    }
  }

  Future<void> _downloadPdf(String url) async {
    final uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Impossible de télécharger le fichier PDF');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon emploi du temps'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('timetables')
            .doc(timetableId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('Emploi du temps introuvable'),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final fileUrl = data['fileUrl'] ?? '';
          final fileName = data['fileName'] ?? 'emploi_du_temps.pdf';
          final adminMessage = data['adminMessage'] ?? '';
          final uploadedAt = data['uploadedAt'] != null
              ? (data['uploadedAt'] as Timestamp).toDate()
              : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.campaign, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Message de l’administration',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          adminMessage.isEmpty
                              ? 'Aucun message de l’administration'
                              : adminMessage,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          uploadedAt != null
                              ? 'Publié le ${DateFormat('dd/MM/yyyy à HH:mm').format(uploadedAt)}'
                              : 'Date non disponible',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE3F2FD),
                      child: Icon(Icons.picture_as_pdf, color: Colors.red),
                    ),
                    title: Text(
                      fileName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      'Cliquez sur un bouton ci-dessous pour ouvrir ou télécharger',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: fileUrl.isEmpty ? null : () => _openPdf(fileUrl),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Ouvrir le PDF'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed:
                        fileUrl.isEmpty ? null : () => _downloadPdf(fileUrl),
                    icon: const Icon(Icons.download),
                    label: const Text('Télécharger le PDF'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}