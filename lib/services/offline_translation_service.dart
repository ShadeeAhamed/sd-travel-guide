import '../ai/translation_data.dart';
import '../models/translation_models.dart';

export '../models/translation_models.dart';

class OfflineTranslationService {
  static TranslationLanguage detectLanguage(
    String text, {
    TranslationLanguage? preferredSpokenLanguage,
  }) {
    if (RegExp(r'[\u0B80-\u0BFF]').hasMatch(text)) {
      return TranslationLanguage.tamil;
    }
    if (RegExp(r'[\u0D80-\u0DFF]').hasMatch(text)) {
      return TranslationLanguage.sinhala;
    }
    if (preferredSpokenLanguage != null &&
        preferredSpokenLanguage != TranslationLanguage.english) {
      return preferredSpokenLanguage;
    }
    return TranslationLanguage.english;
  }

  static String codeFor(TranslationLanguage language) {
    switch (language) {
      case TranslationLanguage.sinhala:
        return "si";
      case TranslationLanguage.tamil:
        return "ta";
      case TranslationLanguage.english:
        return "en";
    }
  }

  static String labelFor(TranslationLanguage language) {
    switch (language) {
      case TranslationLanguage.sinhala:
        return "Sinhala";
      case TranslationLanguage.tamil:
        return "Tamil";
      case TranslationLanguage.english:
        return "English";
    }
  }

  static String localeForSpeech(TranslationLanguage language) {
    switch (language) {
      case TranslationLanguage.sinhala:
        return "si_LK";
      case TranslationLanguage.tamil:
        return "ta_IN";
      case TranslationLanguage.english:
        return "en_US";
    }
  }

  static String ttsLanguage(TranslationLanguage language) {
    switch (language) {
      case TranslationLanguage.sinhala:
        return "si-LK";
      case TranslationLanguage.tamil:
        return "ta-IN";
      case TranslationLanguage.english:
        return "en-US";
    }
  }

  static TranslationResult translateInstant({
    required String text,
    required TranslationLanguage englishTargetLanguage,
    TranslationLanguage? preferredSpokenLanguage,
  }) {
    final cleaned = text.trim();
    final source = detectLanguage(
      cleaned,
      preferredSpokenLanguage: preferredSpokenLanguage,
    );
    final output = source == TranslationLanguage.english
        ? englishTargetLanguage
        : TranslationLanguage.english;

    final translated = cleaned.isEmpty
        ? ""
        : _translateText(
            cleaned,
            source: source,
            target: output,
          );

    return TranslationResult(
      translatedText: translated,
      sourceLanguage: source,
      outputLanguage: output,
      direction: "${codeFor(source)}-${codeFor(output)}",
      fromOfflineDictionary: true,
    );
  }

  static Future<TranslationResult> translateSmart({
    required String text,
    required TranslationLanguage englishTargetLanguage,
    TranslationLanguage? preferredSpokenLanguage,
  }) async {
    return translateInstant(
      text: text,
      englishTargetLanguage: englishTargetLanguage,
      preferredSpokenLanguage: preferredSpokenLanguage,
    );
  }

  static Future<String> translate(String text) async {
    final result = translateInstant(
      text: text,
      englishTargetLanguage: TranslationLanguage.sinhala,
    );
    return result.translatedText;
  }

  static bool hasUsefulLocalTranslation(
    String originalText,
    TranslationResult result,
  ) {
    final original = _simpleNormalize(originalText);
    final translated = _simpleNormalize(result.translatedText);
    return translated.isNotEmpty && translated != original;
  }

  static String _translateText(
    String text, {
    required TranslationLanguage source,
    required TranslationLanguage target,
  }) {
    if (source == target) return text;

    final normalized = _normalizePhraseForLookup(text, source);
    final phraseMap = _phraseMapFor(source, target);
    final wordMap = _wordMapFor(source, target);

    if (phraseMap.containsKey(normalized)) {
      return phraseMap[normalized]!;
    }

    final translatedWords = text
        .split(RegExp(r'\s+'))
        .map((token) => _translateToken(token, wordMap, source))
        .join(" ")
        .trim();

    return translatedWords.isEmpty ? text : translatedWords;
  }

  static String _translateToken(
    String token,
    Map<String, String> wordMap,
    TranslationLanguage source,
  ) {
    final match = RegExp(
      r"^([^A-Za-z0-9\u0B80-\u0BFF\u0D80-\u0DFF]*)([A-Za-z0-9\u0B80-\u0BFF\u0D80-\u0DFF']+)([^A-Za-z0-9\u0B80-\u0BFF\u0D80-\u0DFF]*)$",
    ).firstMatch(token);

    if (match == null) {
      return token;
    }

    final prefix = match.group(1) ?? "";
    final core = match.group(2) ?? "";
    final suffix = match.group(3) ?? "";
    final lookup = _normalizeWordForLookup(core, source);
    final translated = wordMap[lookup] ?? core;

    return "$prefix$translated$suffix";
  }

  static String _normalizePhraseForLookup(
    String text,
    TranslationLanguage source,
  ) {
    final trimmed = text.trim().replaceAll(RegExp(r'\s+'), " ");
    if (source != TranslationLanguage.english) {
      return trimmed;
    }

    final lower = trimmed.toLowerCase();
    final alias = TranslationData.englishAliases[lower];
    return alias ?? lower;
  }

  static String _normalizeWordForLookup(
    String text,
    TranslationLanguage source,
  ) {
    final trimmed = text.trim();
    if (source != TranslationLanguage.english) {
      return trimmed;
    }
    return trimmed.toLowerCase();
  }

  static String _simpleNormalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\u0B80-\u0BFF\u0D80-\u0DFF\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static Map<String, String> _phraseMapFor(
    TranslationLanguage source,
    TranslationLanguage target,
  ) {
    if (source == TranslationLanguage.english &&
        target == TranslationLanguage.sinhala) {
      return TranslationData.enToSiPhrases;
    }
    if (source == TranslationLanguage.sinhala &&
        target == TranslationLanguage.english) {
      return TranslationData.siToEnPhrases;
    }
    if (source == TranslationLanguage.english &&
        target == TranslationLanguage.tamil) {
      return TranslationData.enToTaPhrases;
    }
    if (source == TranslationLanguage.tamil &&
        target == TranslationLanguage.english) {
      return TranslationData.taToEnPhrases;
    }
    return const {};
  }

  static Map<String, String> _wordMapFor(
    TranslationLanguage source,
    TranslationLanguage target,
  ) {
    if (source == TranslationLanguage.english &&
        target == TranslationLanguage.sinhala) {
      return TranslationData.enToSiWords;
    }
    if (source == TranslationLanguage.sinhala &&
        target == TranslationLanguage.english) {
      return TranslationData.siToEnWords;
    }
    if (source == TranslationLanguage.english &&
        target == TranslationLanguage.tamil) {
      return TranslationData.enToTaWords;
    }
    if (source == TranslationLanguage.tamil &&
        target == TranslationLanguage.english) {
      return TranslationData.taToEnWords;
    }
    return const {};
  }
}
