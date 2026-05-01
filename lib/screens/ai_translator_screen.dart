import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../services/ai_translation_service.dart';
import '../services/offline_translation_service.dart';
import '../theme/app_theme.dart';

class AiTranslatorScreen extends StatefulWidget {
  const AiTranslatorScreen({super.key});

  @override
  State<AiTranslatorScreen> createState() => _AiTranslatorScreenState();
}

class _AiTranslatorScreenState extends State<AiTranslatorScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _isListening = false;
  bool _femaleVoice = true;
  bool _autoSpeak = true;
  TranslationLanguage _micLanguage = TranslationLanguage.english;
  TranslationLanguage _englishTargetLanguage = TranslationLanguage.sinhala;
  TranslationResult? _lastResult;

  String inputText = "";
  String translatedText = "";

  Timer? _pauseTimer;
  Timer? _aiRefineTimer;
  int _translationRevision = 0;

  List<DropdownMenuItem<TranslationLanguage>> get _languageItems {
    return TranslationLanguage.values.map((language) {
      return DropdownMenuItem(
        value: language,
        child: Text(OfflineTranslationService.labelFor(language)),
      );
    }).toList();
  }

  List<DropdownMenuItem<TranslationLanguage>> get _targetItems {
    return const [
      DropdownMenuItem(
        value: TranslationLanguage.sinhala,
        child: Text("Sinhala"),
      ),
      DropdownMenuItem(
        value: TranslationLanguage.tamil,
        child: Text("Tamil"),
      ),
    ];
  }

  Future<void> _configureVoice(TranslationLanguage outputLanguage) async {
    await _tts.stop();
    final locale = OfflineTranslationService.ttsLanguage(outputLanguage);
    await _tts.setLanguage(locale);
    await _tts.setVolume(1.0);
    await _applyPreferredVoice(locale);
    await _tts.setPitch(_femaleVoice ? 1.14 : 0.78);
    await _tts.setSpeechRate(_speechRateFor(outputLanguage));
  }

  Future<void> _applyPreferredVoice(String locale) async {
    try {
      final voices = await _tts.getVoices;
      if (voices is! List) return;

      final localeNeedle = locale.toLowerCase().split('-').first;
      final preferredGender = _femaleVoice ? "female" : "male";

      for (final rawVoice in voices) {
        if (rawVoice is! Map) continue;

        final voice = rawVoice.map(
          (key, value) => MapEntry(
            key.toString(),
            value?.toString() ?? "",
          ),
        );

        final voiceLocale = (voice["locale"] ?? "").toLowerCase();
        final voiceGender = (voice["gender"] ?? "").toLowerCase();
        final matchesLocale = voiceLocale.contains(localeNeedle);
        final matchesGender =
            voiceGender.isEmpty || voiceGender.contains(preferredGender);

        if (!matchesLocale || !matchesGender) continue;

        final selection = <String, String>{};
        if ((voice["name"] ?? "").isNotEmpty) {
          selection["name"] = voice["name"]!;
        }
        if ((voice["locale"] ?? "").isNotEmpty) {
          selection["locale"] = voice["locale"]!;
        }
        if ((voice["identifier"] ?? "").isNotEmpty) {
          selection["identifier"] = voice["identifier"]!;
        }

        if (selection.isNotEmpty) {
          await _tts.setVoice(selection);
          return;
        }
      }
    } catch (_) {}
  }

  double _speechRateFor(TranslationLanguage language) {
    if (_femaleVoice) {
      switch (language) {
        case TranslationLanguage.english:
          return 0.44;
        case TranslationLanguage.sinhala:
          return 0.41;
        case TranslationLanguage.tamil:
          return 0.4;
      }
    }

    switch (language) {
      case TranslationLanguage.english:
        return 0.39;
      case TranslationLanguage.sinhala:
        return 0.36;
      case TranslationLanguage.tamil:
        return 0.35;
    }
  }

  Future<void> toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    final available = await _speech.initialize(
      onStatus: (status) {
        if (status == "done" || status == "notListening") {
          if (mounted) setState(() => _isListening = false);
        }
      },
      onError: (error) {
        if (mounted) setState(() => _isListening = false);
      },
    );

    if (!available) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Microphone is unavailable")),
      );
      return;
    }

    setState(() {
      _isListening = true;
      inputText = "";
      translatedText = "";
      _lastResult = null;
    });

    _speech.listen(
      localeId: OfflineTranslationService.localeForSpeech(_micLanguage),
      pauseFor: const Duration(seconds: 4),
      listenFor: const Duration(seconds: 45),
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
      ),
      onResult: (result) async {
        final recognizedText = result.recognizedWords.trim();
        if (recognizedText.isEmpty) return;

        final revision = ++_translationRevision;
        final quickTranslated = OfflineTranslationService.translateInstant(
          text: recognizedText,
          englishTargetLanguage: _englishTargetLanguage,
          preferredSpokenLanguage: _micLanguage,
        );

        if (!mounted) return;
        setState(() {
          inputText = recognizedText;
          _lastResult = quickTranslated;
          translatedText = quickTranslated.translatedText;
        });

        _aiRefineTimer?.cancel();
        _aiRefineTimer = Timer(
          const Duration(milliseconds: 650),
          () => _refineTranslation(recognizedText, revision),
        );

        _pauseTimer?.cancel();
        _pauseTimer = Timer(const Duration(seconds: 2), _handlePause);
      },
    );
  }

  Future<void> _refineTranslation(String recognizedText, int revision) async {
    final translated = await AITranslationService.translateSmart(
      text: recognizedText,
      englishTargetLanguage: _englishTargetLanguage,
      preferredSpokenLanguage: _micLanguage,
    );

    if (!mounted || revision != _translationRevision) return;
    if (inputText.trim() != recognizedText.trim()) return;

    setState(() {
      _lastResult = translated;
      translatedText = translated.translatedText;
    });
  }

  Future<void> _handlePause() async {
    final result = _lastResult;
    if (result == null || translatedText.isEmpty) return;

    await _speech.stop();
    if (mounted) setState(() => _isListening = false);
    if (_autoSpeak) {
      await _speak();
    }
  }

  Future<void> _speak() async {
    final result = _lastResult;
    if (result == null || translatedText.isEmpty) return;

    await _configureVoice(result.outputLanguage);
    await _tts.speak(translatedText);
  }

  @override
  void dispose() {
    _pauseTimer?.cancel();
    _aiRefineTimer?.cancel();
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detectedText = _lastResult == null
        ? "Ready"
        : "${OfflineTranslationService.labelFor(_lastResult!.sourceLanguage)} to ${OfflineTranslationService.labelFor(_lastResult!.outputLanguage)}";

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Voice Translator"),
        actions: [
          IconButton(
            tooltip: "Replay speaker",
            onPressed: translatedText.isEmpty ? null : _speak,
            icon: const Icon(Icons.volume_up),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "Microphone language",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<TranslationLanguage>(
            initialValue: _micLanguage,
            items: _languageItems,
            decoration: _fieldDecoration(Icons.mic),
            onChanged: (value) {
              if (value == null) return;
              setState(() => _micLanguage = value);
            },
          ),
          const SizedBox(height: 18),
          const Text(
            "If speaker uses English, translate to",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<TranslationLanguage>(
            initialValue: _englishTargetLanguage,
            items: _targetItems,
            decoration: _fieldDecoration(Icons.translate),
            onChanged: (value) {
              if (value == null) return;
              setState(() => _englishTargetLanguage = value);
            },
          ),
          const SizedBox(height: 18),
          const Text(
            "Speaker voice",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ChoiceChip(
                label: const Text("Female"),
                selected: _femaleVoice,
                onSelected: (_) => setState(() => _femaleVoice = true),
              ),
              ChoiceChip(
                label: const Text("Male"),
                selected: !_femaleVoice,
                onSelected: (_) => setState(() => _femaleVoice = false),
              ),
              FilterChip(
                label: const Text("Auto speak"),
                selected: _autoSpeak,
                onSelected: (value) => setState(() => _autoSpeak = value),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _statusChip(detectedText),
          const SizedBox(height: 16),
          _box(inputText.isEmpty ? "Speak..." : inputText),
          const SizedBox(height: 16),
          _box(
            translatedText.isEmpty ? "Translation..." : translatedText,
            bold: true,
          ),
          const SizedBox(height: 26),
          Center(
            child: GestureDetector(
              onTap: toggleListening,
              child: CircleAvatar(
                radius: 46,
                backgroundColor: _isListening ? Colors.red : AppColors.gold,
                child: Icon(
                  _isListening ? Icons.stop : Icons.mic,
                  size: 42,
                  color: _isListening ? Colors.white : AppColors.midnight,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _micLanguage == TranslationLanguage.english
                ? "English speech follows the Sinhala/Tamil toggle. Sinhala or Tamil speech is detected by script and translated to English."
                : "${OfflineTranslationService.labelFor(_micLanguage)} speech translates to English. Speaker output uses the matching voice language.",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Chip(
        avatar: const Icon(Icons.auto_awesome, size: 18),
        label: Text(text),
      ),
    );
  }

  InputDecoration _fieldDecoration(IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: AppColors.gold),
      filled: true,
      fillColor: const Color(0xFF151D30),
      hintStyle: const TextStyle(color: Colors.white70),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _box(String text, {bool bold = false}) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 104),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151D30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(10)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: bold ? 19 : 16,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          height: 1.35,
          color: Colors.white,
        ),
      ),
    );
  }
}
