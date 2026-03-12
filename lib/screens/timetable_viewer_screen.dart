import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TimetableViewerScreen extends StatelessWidget {
  final String timetableId;
  final String fileUrl;
  final String fileName;

  const TimetableViewerScreen({
    super.key,
    required this.timetableId,
    required this.fileUrl,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fileName),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.picture_as_pdf, size: 100, color: Colors.red),
            const SizedBox(height: 20),
            Text(fileName, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final Uri url = Uri.parse(fileUrl);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              child: const Text('Ouvrir le PDF'),
            ),
          ],
        ),
      ),
    );
  }
}