import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class UploadService {
  static const int _maxRawBytes = 700 * 1024; // ~700 KB raw, stays under Firestore 1 MB after base64

  String _extensionToMime(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.pdf')) return 'application/pdf';
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    return 'application/octet-stream';
  }

  Future<String?> uploadFile({
    File? file,
    Uint8List? fileBytes,
    required String fileName,
    String folder = 'uploads',
  }) async {
    try {
      debugPrint('Encodage fichier pour Firestore: $folder/$fileName');

      Uint8List bytes;
      if (kIsWeb) {
        if (fileBytes == null) {
          debugPrint('Erreur: fileBytes est null pour le Web');
          return null;
        }
        bytes = fileBytes;
      } else {
        if (file == null) {
          debugPrint('Erreur: file est null pour Mobile');
          return null;
        }
        bytes = await file.readAsBytes();
      }

      if (bytes.length > _maxRawBytes) {
        debugPrint(
          'Fichier trop volumineux: ${bytes.length} bytes (max $_maxRawBytes).',
        );
        return null;
      }

      final mime = _extensionToMime(fileName);
      final base64Data = base64Encode(bytes);
      final dataUrl = 'data:$mime;base64,$base64Data';

      debugPrint('Encodage reussi. Taille base64: ${base64Data.length}');
      return dataUrl;
    } catch (e) {
      debugPrint('Erreur lors de l\'encodage Firestore: $e');
      return null;
    }
  }
}
