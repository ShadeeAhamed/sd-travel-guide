import 'dart:convert';

import 'package:http/http.dart' as http;

import 'offline_translation_service.dart';

class AITranslationService {
  static const String baseUrl = String.fromEnvironment(
    "TRANSLATION_API_URL",
    defaultValue: "http://10.0.2.2:8000/translate",
  );

  static Future<TranslationResult> translateSmart({
    required String text,
    required TranslationLanguage englishTargetLanguage,
    TranslationLanguage? preferredSpokenLanguage,
  }) async {
    final source = OfflineTranslationService.detectLanguage(
      text,
      
      preferredSpokenLanguage: preferredSpokenLanguage,
    );
    final output = source == TranslationLanguage.english
        ? englishTargetLanguage
        : TranslationLanguage.english;
    final direction =
        "${OfflineTranslationService.codeFor(source)}-${OfflineTranslationService.codeFor(output)}";

    final offline = OfflineTranslationService.translateInstant(
      text: text,
      englishTargetLanguage: englishTargetLanguage,
      preferredSpokenLanguage: preferredSpokenLanguage,
    );

    final wordCount = text
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .length;

    if (OfflineTranslationService.hasUsefulLocalTranslation(text, offline) &&
        wordCount <= 4) {
      return offline;
    }

    if (baseUrl.trim().isEmpty) return offline;

    try {
      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "text": text,
              "direction": direction,
              "source": OfflineTranslationService.codeFor(source),
              "target": OfflineTranslationService.codeFor(output),
            }),
          )
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final translated =
              decoded["translated_text"] ?? decoded["translatedText"];
          final found = decoded["found"];

          if (found == false) {
            return offline;
          }

          if (translated is String &&
              translated.trim().isNotEmpty &&
              translated != "Translation not found in local model.") {
            return TranslationResult(
              translatedText: translated.trim(),
              sourceLanguage: source,
              outputLanguage: output,
              direction: direction,
              fromOfflineDictionary: false,
            );
          }
        }
      }
    } catch (_) {}

    return offline;
  }

  static Future<String> translate(String text, String direction) async {
    final parts = direction.split("-");
    final source = _languageFromCode(parts.first);
    final output = _languageFromCode(parts.length > 1 ? parts.last : "en");
    final result = await translateSmart(
      text: text,
      englishTargetLanguage: output == TranslationLanguage.english
          ? TranslationLanguage.sinhala
          : output,
      preferredSpokenLanguage: source,
    );
    return result.translatedText;
  }

  static TranslationLanguage _languageFromCode(String code) {
    switch (code) {
      case "si":
        return TranslationLanguage.sinhala;
      case "ta":
        return TranslationLanguage.tamil;
      case "en":
      default:
        return TranslationLanguage.english;
    }
  }
}
