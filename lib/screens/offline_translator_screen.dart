import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../services/offline_translation_service.dart';
import '../theme/app_theme.dart';

class OfflineTranslatorScreen extends StatefulWidget {
  const OfflineTranslatorScreen({super.key});

  @override
  State<OfflineTranslatorScreen> createState() =>
      _OfflineTranslatorScreenState();
}

class _OfflineTranslatorScreenState extends State<OfflineTranslatorScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _isListening = false;
  TranslationLanguage _micLanguage = TranslationLanguage.english;
  TranslationLanguage _englishTargetLanguage = TranslationLanguage.sinhala;
  TranslationResult? _lastResult;
  String inputText = "";
  String translatedText = "";

  Timer? _pauseTimer;

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
      onError: (_) {
        if (mounted) setState(() => _isListening = false);
      },
    );
    if (!available) return;

    setState(() {
      _isListening = true;
      inputText = "";
      translatedText = "";
      _lastResult = null;
    });

    _speech.listen(
      localeId: OfflineTranslationService.localeForSpeech(_micLanguage),
      listenFor: const Duration(seconds: 35),
      pauseFor: const Duration(seconds: 4),
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
      ),
      onResult: (result) async {
        final recognizedText = result.recognizedWords.trim();
        if (recognizedText.isEmpty) return;

        final translated = OfflineTranslationService.translateInstant(
          text: recognizedText,
          englishTargetLanguage: _englishTargetLanguage,
          preferredSpokenLanguage: _micLanguage,
        );

        if (!mounted) return;
        setState(() {
          inputText = recognizedText;
          _lastResult = translated;
          translatedText = translated.translatedText;
        });

        _pauseTimer?.cancel();
        _pauseTimer = Timer(const Duration(seconds: 2), _handlePause);
      },
    );
  }

  Future<void> _handlePause() async {
    if (_lastResult == null || translatedText.isEmpty) return;

    await _speech.stop();
    if (mounted) setState(() => _isListening = false);
    await _speak();
  }

  Future<void> _speak() async {
    final result = _lastResult;
    if (result == null || translatedText.isEmpty) return;

    await _tts.stop();
    await _tts.setLanguage(
      OfflineTranslationService.ttsLanguage(result.outputLanguage),
    );
    await _tts.setSpeechRate(0.44);
    await _tts.speak(translatedText);
  }

  @override
  void dispose() {
    _pauseTimer?.cancel();
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Offline Translator"),
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
            "English target",
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
        ],
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
}
