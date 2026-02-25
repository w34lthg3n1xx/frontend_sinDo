import 'dart:io';
import 'package:mime/mime.dart';

class Validators {
  static String? validateText(String? text) {
    if (text != null && text.length > 3000) {
      return 'Le texte ne doit pas dépasser 3000 caractères.';
    }
    return null;
  }

  static String? validateFile(File? file) {
    if (file == null) return null;

    if (file.lengthSync() > 5 * 1024 * 1024) {
      return 'Le fichier ne doit pas dépasser 5 MB.';
    }

    final mimeType = lookupMimeType(file.path);
    if (mimeType == null || (!mimeType.startsWith('image/') && mimeType != 'application/pdf')) {
      return 'Format de fichier non supporté. Uniquement les images et les PDF sont autorisés.';
    }

    return null;
  }

  static String? sanitizeText(String? text) {
    if (text == null) return null;
    // Basic sanitization: remove potential harmful characters.
    // This is not a replacement for proper backend validation.
    return text.replaceAll(RegExp(r'[<>$]'), '');
  }
}
