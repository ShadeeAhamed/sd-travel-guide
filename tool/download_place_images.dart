import 'dart:convert';
import 'dart:io';

class PlaceImageSpec {
  final String name;
  final String folder;
  final List<String> queries;

  const PlaceImageSpec({
    required this.name,
    required this.folder,
    required this.queries,
  });
}

class DownloadedImage {
  final String assetPath;
  final String pageTitle;
  final String pageUrl;
  final String imageUrl;

  const DownloadedImage({
    required this.assetPath,
    required this.pageTitle,
    required this.pageUrl,
    required this.imageUrl,
  });
}

const _specs = <PlaceImageSpec>[
  PlaceImageSpec(
    name: 'Ella',
    folder: 'ella',
    queries: ['Nine Arch Bridge', 'Ella Sri Lanka', 'Ravana Falls'],
  ),
  PlaceImageSpec(
    name: 'Sigiriya',
    folder: 'sigiriya',
    queries: ['Sigiriya', 'Pidurangala', 'Sigiriya frescoes'],
  ),
  PlaceImageSpec(
    name: 'Kandy',
    folder: 'kandy',
    queries: [
      'Temple of the Tooth',
      'Kandy Lake',
      'Royal Botanical Gardens Peradeniya',
    ],
  ),
  PlaceImageSpec(
    name: 'Galle',
    folder: 'galle',
    queries: ['Galle Fort', 'Galle Lighthouse', 'Dutch Reformed Church Galle'],
  ),
  PlaceImageSpec(
    name: 'Mirissa',
    folder: 'mirissa',
    queries: ['Mirissa', 'Parrot Rock Mirissa', 'Weligama'],
  ),
  PlaceImageSpec(
    name: 'Nuwara Eliya',
    folder: 'nuwara_eliya',
    queries: ['Nuwara Eliya', 'Gregory Lake', 'Hakgala Botanical Garden'],
  ),
  PlaceImageSpec(
    name: 'Yala National Park',
    folder: 'yala_national_park',
    queries: ['Yala National Park', 'Sri Lankan leopard', 'Yala Block 1'],
  ),
  PlaceImageSpec(
    name: 'Trincomalee',
    folder: 'trincomalee',
    queries: ['Nilaveli', 'Koneswaram Temple', 'Pigeon Island National Park'],
  ),
  PlaceImageSpec(
    name: 'Arugam Bay',
    folder: 'arugam_bay',
    queries: ['Arugam Bay', 'Panama Sri Lanka', 'Kumana National Park'],
  ),
  PlaceImageSpec(
    name: 'Colombo',
    folder: 'colombo',
    queries: ['Galle Face Green', 'Gangaramaya Temple', 'Colombo Lotus Tower'],
  ),
  PlaceImageSpec(
    name: 'Anuradhapura',
    folder: 'anuradhapura',
    queries: ['Ruwanwelisaya', 'Jaya Sri Maha Bodhi', 'Anuradhapura'],
  ),
  PlaceImageSpec(
    name: 'Polonnaruwa',
    folder: 'polonnaruwa',
    queries: ['Gal Vihara', 'Polonnaruwa Vatadage', 'Polonnaruwa'],
  ),
  PlaceImageSpec(
    name: 'Dambulla',
    folder: 'dambulla',
    queries: ['Dambulla cave temple', 'Golden Temple of Dambulla', 'Dambulla'],
  ),
  PlaceImageSpec(
    name: 'Unawatuna',
    folder: 'unawatuna',
    queries: ['Unawatuna', 'Jungle Beach Sri Lanka', 'Galle'],
  ),
  PlaceImageSpec(
    name: 'Hikkaduwa',
    folder: 'hikkaduwa',
    queries: ['Hikkaduwa Beach', 'Hikkaduwa National Park', 'Hikkaduwa'],
  ),
  PlaceImageSpec(
    name: 'Bentota',
    folder: 'bentota',
    queries: ['Bentota', 'Bentota River', 'Brief Garden'],
  ),
  PlaceImageSpec(
    name: 'Jaffna',
    folder: 'jaffna',
    queries: ['Nallur Kandaswamy Temple', 'Jaffna Fort', 'Jaffna'],
  ),
  PlaceImageSpec(
    name: 'Horton Plains',
    folder: 'horton_plains',
    queries: [
      'Horton Plains National Park',
      "World's End Sri Lanka",
      "Baker's Falls",
    ],
  ),
  PlaceImageSpec(
    name: 'Pidurangala',
    folder: 'pidurangala',
    queries: ['Pidurangala', 'Pidurangala Rock', 'Sigiriya'],
  ),
  PlaceImageSpec(
    name: 'Udawalawe',
    folder: 'udawalawe',
    queries: ['Udawalawe National Park', 'Elephant Transit Home', 'Udawalawe'],
  ),
];

Future<void> main() async {
  final client = HttpClient()..userAgent = 'tourist-guide-app/1.0';
  final coverAssets = <String, String>{};
  final galleryAssets = <String, List<String>>{};
  final wikipediaTitles = <String, String>{};
  final attribution = StringBuffer()
    ..writeln('# Place Image Sources')
    ..writeln()
    ..writeln('Downloaded from free-license Wikimedia Commons images via Wikipedia APIs.')
    ..writeln();

  try {
    for (final spec in _specs) {
      final folder = Directory('assets/places/${spec.folder}');
      if (!folder.existsSync()) {
        folder.createSync(recursive: true);
      }

      for (final entity in folder.listSync()) {
        if (entity is File &&
            (entity.path.endsWith('.jpg') ||
                entity.path.endsWith('.jpeg') ||
                entity.path.endsWith('.png') ||
                entity.path.endsWith('.webp'))) {
          entity.deleteSync();
        }
      }

      final seenUrls = <String>{};
      final downloads = <DownloadedImage>[];

      for (final query in spec.queries) {
        if (downloads.length >= 3) {
          break;
        }

        final pageTitle = await _searchFirstPageTitle(client, query);
        if (pageTitle == null || pageTitle.isEmpty) {
          stderr.writeln('No page found for query "$query".');
          continue;
        }

        final summary = await _fetchSummary(client, pageTitle);
        if (summary == null) {
          stderr.writeln('No summary found for "$pageTitle".');
          continue;
        }

        final imageUrl = _extractImageUrl(summary);
        if (imageUrl == null || imageUrl.isEmpty || !seenUrls.add(imageUrl)) {
          continue;
        }

        final extension = _fileExtensionFromUrl(imageUrl);
        final filename =
            downloads.isEmpty ? 'cover$extension' : '${downloads.length}$extension';
        final assetPath = 'assets/places/${spec.folder}/$filename';
        final outputFile = File(assetPath);

        final bytes = await _downloadBytes(client, imageUrl);
        if (bytes == null || bytes.isEmpty) {
          stderr.writeln('Could not download image for "$pageTitle".');
          continue;
        }

        outputFile.writeAsBytesSync(bytes, flush: true);
        final pageUrl =
            'https://en.wikipedia.org/wiki/${Uri.encodeComponent(pageTitle.replaceAll(' ', '_'))}';
        downloads.add(
          DownloadedImage(
            assetPath: assetPath.replaceAll('\\', '/'),
            pageTitle: pageTitle,
            pageUrl: pageUrl,
            imageUrl: imageUrl,
          ),
        );
      }

      if (downloads.isEmpty) {
        stderr.writeln('No images downloaded for ${spec.name}.');
        continue;
      }

      coverAssets[spec.name] = downloads.first.assetPath;
      galleryAssets[spec.name] = downloads.map((image) => image.assetPath).toList();
      wikipediaTitles[spec.name] = downloads.first.pageTitle;

      attribution.writeln('## ${spec.name}');
      for (final image in downloads) {
        attribution.writeln('- ${image.pageTitle}: ${image.pageUrl}');
        attribution.writeln('  - Image: ${image.imageUrl}');
      }
      attribution.writeln();
    }

    final photoDataFile = File('lib/data/place_photo_data.dart');
    photoDataFile.writeAsStringSync(
      _buildPhotoDataDart(
        wikipediaTitles: wikipediaTitles,
        coverAssets: coverAssets,
        galleryAssets: galleryAssets,
      ),
      flush: true,
    );

    final attributionFile = File('assets/places/ATTRIBUTION.md');
    attributionFile.writeAsStringSync(attribution.toString(), flush: true);
  } finally {
    client.close(force: true);
  }
}

Future<String?> _searchFirstPageTitle(HttpClient client, String query) async {
  final uri = Uri.parse(
    'https://en.wikipedia.org/w/api.php?action=query&list=search&format=json&srlimit=1&srsearch=${Uri.encodeQueryComponent(query)}',
  );
  final json = await _getJson(client, uri);
  final queryData = json?['query'];
  if (queryData is! Map<String, dynamic>) {
    return null;
  }
  final search = queryData['search'];
  if (search is! List || search.isEmpty || search.first is! Map<String, dynamic>) {
    return null;
  }
  return search.first['title']?.toString();
}

Future<Map<String, dynamic>?> _fetchSummary(
  HttpClient client,
  String pageTitle,
) async {
  final uri = Uri.parse(
    'https://en.wikipedia.org/api/rest_v1/page/summary/${Uri.encodeComponent(pageTitle)}',
  );
  final json = await _getJson(client, uri);
  if (json is Map<String, dynamic>) {
    return json;
  }
  return null;
}

String? _extractImageUrl(Map<String, dynamic> summary) {
  final original = summary['originalimage'];
  if (original is Map<String, dynamic>) {
    final source = original['source'];
    if (source is String && source.trim().isNotEmpty) {
      return source.trim();
    }
  }

  final thumbnail = summary['thumbnail'];
  if (thumbnail is Map<String, dynamic>) {
    final source = thumbnail['source'];
    if (source is String && source.trim().isNotEmpty) {
      return source.trim();
    }
  }

  return null;
}

Future<Map<String, dynamic>?> _getJson(HttpClient client, Uri uri) async {
  try {
    final request = await client.getUrl(uri);
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    final response = await request.close();
    if (response.statusCode != 200) {
      return null;
    }
    final body = await utf8.decodeStream(response);
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
  } catch (_) {}
  return null;
}

Future<List<int>?> _downloadBytes(HttpClient client, String imageUrl) async {
  try {
    final request = await client.getUrl(Uri.parse(imageUrl));
    final response = await request.close();
    if (response.statusCode != 200) {
      return null;
    }
    final builder = BytesBuilder(copy: false);
    await for (final chunk in response) {
      builder.add(chunk);
    }
    return builder.takeBytes();
  } catch (_) {
    return null;
  }
}

String _fileExtensionFromUrl(String url) {
  final path = Uri.parse(url).path.toLowerCase();
  if (path.endsWith('.png')) return '.png';
  if (path.endsWith('.webp')) return '.webp';
  if (path.endsWith('.jpeg')) return '.jpeg';
  return '.jpg';
}

String _buildPhotoDataDart({
  required Map<String, String> wikipediaTitles,
  required Map<String, String> coverAssets,
  required Map<String, List<String>> galleryAssets,
}) {
  final buffer = StringBuffer();
  buffer.writeln('const Map<String, String> wikipediaPlaceTitles = {');
  for (final entry in wikipediaTitles.entries) {
    buffer.writeln("  '${_escape(entry.key)}': '${_escape(entry.value)}',");
  }
  buffer.writeln('};');
  buffer.writeln();
  buffer.writeln('const Map<String, String> localCoverAssets = {');
  for (final entry in coverAssets.entries) {
    buffer.writeln("  '${_escape(entry.key)}': '${_escape(entry.value)}',");
  }
  buffer.writeln('};');
  buffer.writeln();
  buffer.writeln('const Map<String, List<String>> localPlaceGalleryAssets = {');
  for (final entry in galleryAssets.entries) {
    buffer.writeln("  '${_escape(entry.key)}': [");
    for (final asset in entry.value) {
      buffer.writeln("    '${_escape(asset)}',");
    }
    buffer.writeln('  ],');
  }
  buffer.writeln('};');
  buffer.writeln();
  buffer.writeln('String wikipediaTitleForPlace(String placeName) {');
  buffer.writeln('  return wikipediaPlaceTitles[placeName] ?? placeName;');
  buffer.writeln('}');
  buffer.writeln();
  buffer.writeln('bool hasDedicatedLocalPhotos(String placeName) {');
  buffer.writeln('  return localCoverAssets.containsKey(placeName);');
  buffer.writeln('}');
  buffer.writeln();
  buffer.writeln('String? localCoverAssetForPlace(String placeName) {');
  buffer.writeln('  return localCoverAssets[placeName];');
  buffer.writeln('}');
  buffer.writeln();
  buffer.writeln('List<String> localGalleryAssetsForPlace(String placeName) {');
  buffer.writeln(
    '  return List<String>.from(localPlaceGalleryAssets[placeName] ?? const <String>[]);',
  );
  buffer.writeln('}');
  return buffer.toString();
}

String _escape(String value) {
  return value.replaceAll(r'\', r'\\').replaceAll("'", r"\'");
}
