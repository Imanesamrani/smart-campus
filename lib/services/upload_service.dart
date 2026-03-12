import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class UploadService {
  // Liste de services gratuits (on essaie chacun jusqu'à ce qu'un fonctionne)
  final List<Map<String, String>> _uploadServices = [
    {
      'url': 'https://tmp.ninja/api.php?d=upload-tmp',
      'field': 'file',
    },
    {
      'url': 'https://file.io/?expires=1w',
      'field': 'file',
    },
    {
      'url': 'https://transfer.sh',
      'field': 'file',
    },
  ];
  
  Future<String?> uploadFile({
    File? file,
    Uint8List? fileBytes,
    required String fileName,
  }) async {
    // Essayer chaque service jusqu'à succès
    for (var service in _uploadServices) {
      try {
        final url = service['url']!;
        final field = service['field']!;
        
        debugPrint('Tentative d\'upload vers: $url');
        
        var request = http.MultipartRequest('POST', Uri.parse(url));
        
        if (kIsWeb) {
          if (fileBytes == null) continue;
          var multipartFile = http.MultipartFile.fromBytes(
            field,
            fileBytes,
            filename: fileName,
          );
          request.files.add(multipartFile);
        } else {
          if (file == null) continue;
          var multipartFile = await http.MultipartFile.fromPath(
            field,
            file.path,
            filename: fileName,
          );
          request.files.add(multipartFile);
        }

        var response = await request.send();
        var responseData = await response.stream.bytesToString();
        
        debugPrint('Réponse: $responseData');
        
        // Analyser la réponse selon le service
        if (url.contains('tmp.ninja')) {
          // tmp.ninja retourne directement l'URL
          return responseData.trim();
        } else if (url.contains('file.io')) {
          final json = jsonDecode(responseData);
          if (json['success'] == true) {
            return json['link'];
          }
        } else if (url.contains('transfer.sh')) {
          // transfer.sh retourne l'URL directement
          return responseData.trim();
        }
      } catch (e) {
        debugPrint('Erreur avec ${service['url']}: $e');
        continue; // Essayer le service suivant
      }
    }
    
    // Si tous les services échouent, utiliser une approche alternative
    return _uploadToGist(fileBytes ?? await file!.readAsBytes(), fileName);
  }

  // Solution de secours : encoder en base64 et stocker temporairement
  Future<String?> _uploadToGist(Uint8List bytes, String fileName) async {
    try {
      // Convertir en base64
      String base64Data = base64Encode(bytes);
      
      // Créer un contenu HTML avec un lien data URL
      String htmlContent = '''
<!DOCTYPE html>
<html>
<head><title>$fileName</title></head>
<body>
  <script>
    const byteCharacters = atob("$base64Data");
    const byteNumbers = new Array(byteCharacters.length);
    for (let i = 0; i < byteCharacters.length; i++) {
      byteNumbers[i] = byteCharacters.charCodeAt(i);
    }
    const byteArray = new Uint8Array(byteNumbers);
    const blob = new Blob([byteArray], { type: 'application/pdf' });
    const url = URL.createObjectURL(blob);
    window.location.href = url;
  </script>
</body>
</html>
      ''';
      
      // Uploader ce HTML vers un service (ou le sauvegarder localement)
      // Pour l'instant, on retourne une data URL
      return 'data:application/pdf;base64,$base64Data';
    } catch (e) {
      debugPrint('Erreur upload secours: $e');
      return null;
    }
  }
}