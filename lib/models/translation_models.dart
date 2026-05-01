enum TranslationLanguage {
  english,
  sinhala,
  tamil,
}

class TranslationResult {
  final String translatedText;
  final TranslationLanguage sourceLanguage;
  final TranslationLanguage outputLanguage;
  final String direction;
  final bool fromOfflineDictionary;

  const TranslationResult({
    required this.translatedText,
    required this.sourceLanguage,
    required this.outputLanguage,
    required this.direction,
    required this.fromOfflineDictionary,
  });
}
