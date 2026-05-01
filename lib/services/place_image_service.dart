import 'dart:convert';

import 'package:http/http.dart' as http;

import '../data/place_photo_data.dart';

class PlaceImageService {
  static final Map<String, Future<String?>> _urlCache = {};

  static Future<String?> resolveImageUrl(
    String placeName, {
    String? wikipediaTitle,
  }) {
    final title = (wikipediaTitle ?? wikipediaTitleForPlace(placeName)).trim();
    return _urlCache.putIfAbsent(title, () => _fetchImageUrl(title));
  }

  static Future<String?> _fetchImageUrl(String title) async {
    try {
      final encodedTitle = Uri.encodeComponent(title);
      final uri = Uri.parse(
        "https://en.wikipedia.org/api/rest_v1/page/summary/$encodedTitle",
      );
      final response = await http.get(
        uri,
        headers: const {
          "Accept": "application/json",
          "User-Agent": "tourist-guide-app/1.0",
        },
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode != 200) {
        return null;
      }

      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic>) {
        return null;
      }

      final original = data["originalimage"];
      if (original is Map<String, dynamic>) {
        final source = original["source"];
        if (source is String && source.trim().isNotEmpty) {
          return source.trim();
        }
      }

      final thumbnail = data["thumbnail"];
      if (thumbnail is Map<String, dynamic>) {
        final source = thumbnail["source"];
        if (source is String && source.trim().isNotEmpty) {
          return source.trim();
        }
      }
    } catch (_) {}

    return null;
  }
}
