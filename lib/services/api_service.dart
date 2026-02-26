import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import '../models/api_response.dart';

class ApiService {
  // Replace with your actual backend URL
  static const String _baseUrl = 'https://edris-demiurgical-andy.ngrok-free.dev/analyze';

  Future<ApiResponse> analyze(
      {String? text, File? file, String? videoUrl}) async {

    // Code original de l'appel API (commenté pour le test)
    final uri = Uri.parse(_baseUrl);
    final request = http.MultipartRequest('POST', uri);

    if (text != null && text.isNotEmpty) {
      request.fields['text'] = text;
    }
    if (videoUrl != null && videoUrl.isNotEmpty) {
      request.fields['video_url'] = videoUrl;
    }

    if (file != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
        filename: p.basename(file.path),
      ));
    }
    
    try {
      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return ApiResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        throw _handleError(response.statusCode, response.body);
      }
    } on TimeoutException {
        throw 'La requête a expiré. Veuillez réessayer.';
    } on SocketException {
        throw 'Problème réseau. Vérifiez votre connexion internet.';
    } catch (e) {
      throw 'Une erreur inattendue est survenue: $e';
    }
    
  }

  String _handleError(int statusCode, String body) {
    switch (statusCode) {
      case 400:
        return 'Erreur de requête. Veuillez vérifier les données envoyées.';
      case 413:
        return 'Fichier trop volumineux. La taille maximale est de 5 MB.';
      case 500:
        return 'Erreur serveur interne. Veuillez réessayer plus tard.';
      default:
        return 'Erreur de communication avec le serveur (Code: $statusCode).';
    }
  }
}
