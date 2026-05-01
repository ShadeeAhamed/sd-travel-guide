import 'dart:convert';
import 'dart:io';

class PlaceImageSpec {
  final String name;
  final String folder;
  final String wikipediaTitle;
  final List<String> queries;
  final List<String> manualCommonsFiles;

  const PlaceImageSpec({
    required this.name,
    required this.folder,
    required this.wikipediaTitle,
    required this.queries,
    this.manualCommonsFiles = const [],
  });
}

class CommonsImageResult {
  final String title;
  final String pageUrl;
  final String imageUrl;

  const CommonsImageResult({
    required this.title,
    required this.pageUrl,
    required this.imageUrl,
  });
}

const _specs = <PlaceImageSpec>[
  PlaceImageSpec(
    name: 'Ella',
    folder: 'ella',
    wikipediaTitle: 'Nine Arch Bridge',
    queries: ['Nine Arch Bridge', 'Ella Sri Lanka', 'Ravana Falls Sri Lanka'],
  ),
  PlaceImageSpec(
    name: 'Sigiriya',
    folder: 'sigiriya',
    wikipediaTitle: 'Sigiriya',
    queries: ['Sigiriya', 'Sigiriya frescoes', 'Sigiriya Rock Fortress'],
  ),
  PlaceImageSpec(
    name: 'Kandy',
    folder: 'kandy',
    wikipediaTitle: 'Temple of the Tooth',
    queries: [
      'Temple of the Tooth Sri Lanka',
      'Kandy Lake',
      'Royal Botanic Gardens Peradeniya',
    ],
  ),
  PlaceImageSpec(
    name: 'Galle',
    folder: 'galle',
    wikipediaTitle: 'Galle Fort',
    queries: ['Galle Fort Sri Lanka', 'Galle lighthouse', 'Galle ramparts'],
    manualCommonsFiles: [
      'Galle Fort walls South Sri Lanka.jpg',
    ],
  ),
  PlaceImageSpec(
    name: 'Mirissa',
    folder: 'mirissa',
    wikipediaTitle: 'Weligama',
    queries: ['Mirissa beach Sri Lanka', 'Parrot Rock Mirissa', 'Weligama beach'],
  ),
  PlaceImageSpec(
    name: 'Nuwara Eliya',
    folder: 'nuwara_eliya',
    wikipediaTitle: 'Hakgala Botanical Garden',
    queries: [
      'Nuwara Eliya Sri Lanka',
      'Gregory Lake Sri Lanka',
      'Hakgala Botanical Garden',
    ],
  ),
  PlaceImageSpec(
    name: 'Yala National Park',
    folder: 'yala_national_park',
    wikipediaTitle: 'Yala National Park',
    queries: [
      'Yala National Park Sri Lanka',
      'Yala safari jeep',
      'Sri Lankan leopard Yala',
    ],
  ),
  PlaceImageSpec(
    name: 'Trincomalee',
    folder: 'trincomalee',
    wikipediaTitle: 'Nilaveli',
    queries: [
      'Trincomalee Sri Lanka beach',
      'Nilaveli beach',
      'Pigeon Island National Park Sri Lanka',
    ],
    manualCommonsFiles: [
      'Trinquemalay, retour des pêcheurs au Sri-Lanka (1).jpg',
    ],
  ),
  PlaceImageSpec(
    name: 'Arugam Bay',
    folder: 'arugam_bay',
    wikipediaTitle: 'Arugam Bay',
    queries: ['Arugam Bay Sri Lanka', 'Arugam Bay surf', 'Arugam Bay beach'],
  ),
  PlaceImageSpec(
    name: 'Colombo',
    folder: 'colombo',
    wikipediaTitle: 'Galle Face Green',
    queries: ['Galle Face Green', 'Gangaramaya Temple', 'Lotus Tower Colombo'],
  ),
  PlaceImageSpec(
    name: 'Anuradhapura',
    folder: 'anuradhapura',
    wikipediaTitle: 'Anuradhapura',
    queries: ['Anuradhapura Sri Lanka', 'Ruwanwelisaya', 'Jaya Sri Maha Bodhi'],
  ),
  PlaceImageSpec(
    name: 'Polonnaruwa',
    folder: 'polonnaruwa',
    wikipediaTitle: 'Polonnaruwa Vatadage',
    queries: ['Polonnaruwa Vatadage', 'Gal Vihara', 'Polonnaruwa Sri Lanka'],
    manualCommonsFiles: [
      'Vatadage.jpg',
      'Gal Vihara Polonnaruwa Sri Lanka.jpg',
    ],
  ),
  PlaceImageSpec(
    name: 'Dambulla',
    folder: 'dambulla',
    wikipediaTitle: 'Dambulla cave temple',
    queries: [
      'Dambulla cave temple',
      'Golden Temple of Dambulla',
      'Dambulla Sri Lanka',
    ],
  ),
  PlaceImageSpec(
    name: 'Unawatuna',
    folder: 'unawatuna',
    wikipediaTitle: 'Unawatuna',
    queries: ['Unawatuna beach Sri Lanka', 'Jungle Beach Sri Lanka', 'Unawatuna bay'],
    manualCommonsFiles: [
      'Unawatuna beach.jpg',
      'Unawatuna beach sri lanka.jpg',
    ],
  ),
  PlaceImageSpec(
    name: 'Hikkaduwa',
    folder: 'hikkaduwa',
    wikipediaTitle: 'Hikkaduwa',
    queries: ['Hikkaduwa beach Sri Lanka', 'Hikkaduwa coral', 'Hikkaduwa sea turtle'],
    manualCommonsFiles: [
      'Hikkaduwa beach Sri Lanka.jpg',
      'Hikkaduwa Beach Sri Lanka.jpg',
    ],
  ),
  PlaceImageSpec(
    name: 'Bentota',
    folder: 'bentota',
    wikipediaTitle: 'Bentota',
    queries: ['Bentota beach Sri Lanka', 'Bentota river', 'Bentota resort beach'],
    manualCommonsFiles: [
      'https://upload.wikimedia.org/wikipedia/commons/4/41/Sri_Lanka%2C_Bentota%2C_beach_%281%29.JPG',
    ],
  ),
  PlaceImageSpec(
    name: 'Jaffna',
    folder: 'jaffna',
    wikipediaTitle: 'Jaffna',
    queries: ['Jaffna Sri Lanka', 'Nallur Kandaswamy Temple', 'Jaffna Fort'],
    manualCommonsFiles: [
      'Jaffna Fort (1).jpg',
      'Jaffna Fort (2).jpg',
      'Jaffna Fort (3).jpg',
    ],
  ),
  PlaceImageSpec(
    name: 'Horton Plains',
    folder: 'horton_plains',
    wikipediaTitle: 'Horton Plains National Park',
    queries: [
      'Horton Plains National Park',
      "World's End Sri Lanka",
      "Baker's Falls Sri Lanka",
    ],
    manualCommonsFiles: [
      'Horton plains - Sri Lanka.jpg',
      'Horton Plains Sri Lanka.jpg',
    ],
  ),
  PlaceImageSpec(
    name: 'Pidurangala',
    folder: 'pidurangala',
    wikipediaTitle: 'Pidurangala',
    queries: ['Pidurangala Sri Lanka', 'Pidurangala Rock', 'Pidurangala sunrise'],
    manualCommonsFiles: [
      'Pidurangala Rock.jpg',
      'Pidurangala Rocks.jpg',
    ],
  ),
  PlaceImageSpec(
    name: 'Udawalawe',
    folder: 'udawalawe',
    wikipediaTitle: 'Udawalawe National Park',
    queries: ['Udawalawe National Park', 'Udawalawe elephant', 'Elephant Transit Home'],
    manualCommonsFiles: [
      'Udawalawe national park.jpg',
    ],
  ),
];

Future<void> main() async {
  final client = HttpClient()..userAgent = 'tourist-guide-app/1.0';
  final attributionEntries = <String, List<CommonsImageResult>>{};

  try {
    for (final spec in _specs) {
      final folder = Directory('assets/places/${spec.folder}');
      folder.createSync(recursive: true);

      var localImages = _listLocalImages(folder);
      if (localImages.length >= 3) {
        continue;
      }

      final seenUrls = <String>{};
      final newEntries = <CommonsImageResult>[];

      for (final fileTitle in spec.manualCommonsFiles) {
        if (localImages.length >= 3) {
          break;
        }

        final result = _manualCommonsResult(fileTitle);
        if (!seenUrls.add(result.imageUrl) || _shouldSkipTitle(result.title)) {
          continue;
        }

        final bytes = await _downloadBytes(client, result.imageUrl);
        if (bytes == null || bytes.isEmpty) {
          continue;
        }

        final filename = _nextFileName(folder, result.imageUrl);
        final output = File('${folder.path}/$filename');
        output.writeAsBytesSync(bytes, flush: true);
        newEntries.add(result);
        localImages = _listLocalImages(folder);
      }

      final exactTitles = <String>{
        spec.wikipediaTitle,
        ...spec.queries,
      };
      for (final title in exactTitles) {
        if (localImages.length >= 3) {
          break;
        }

        final result = await _fetchWikipediaSummaryImage(client, title);
        if (result == null ||
            !seenUrls.add(result.imageUrl) ||
            _shouldSkipTitle(result.title)) {
          continue;
        }

        final bytes = await _downloadBytes(client, result.imageUrl);
        if (bytes == null || bytes.isEmpty) {
          continue;
        }

        final filename = _nextFileName(folder, result.imageUrl);
        final output = File('${folder.path}/$filename');
        output.writeAsBytesSync(bytes, flush: true);
        newEntries.add(result);
        localImages = _listLocalImages(folder);
      }

      for (final query in spec.queries) {
        if (localImages.length >= 3) {
          break;
        }

        final results = await _searchCommonsImages(client, query);
        for (final result in results) {
          if (localImages.length >= 3) {
            break;
          }
          if (!seenUrls.add(result.imageUrl) || _shouldSkipTitle(result.title)) {
            continue;
          }

          final bytes = await _downloadBytes(client, result.imageUrl);
          if (bytes == null || bytes.isEmpty) {
            continue;
          }

          final filename = _nextFileName(folder, result.imageUrl);
          final output = File('${folder.path}/$filename');
          output.writeAsBytesSync(bytes, flush: true);
          newEntries.add(result);
          localImages = _listLocalImages(folder);
        }
      }

      if (newEntries.isNotEmpty) {
        attributionEntries[spec.name] = newEntries;
      }
    }

    File('lib/data/place_photo_data.dart').writeAsStringSync(
      _buildPhotoDataDart(_specs),
      flush: true,
    );

    _appendAttribution(attributionEntries);
  } finally {
    client.close(force: true);
  }
}

List<File> _listLocalImages(Directory folder) {
  final files = folder
      .listSync()
      .whereType<File>()
      .where((file) {
        final path = file.path.toLowerCase();
        return path.endsWith('.jpg') ||
            path.endsWith('.jpeg') ||
            path.endsWith('.png') ||
            path.endsWith('.webp');
      })
      .toList();

  files.sort((a, b) => _sortKey(a.path).compareTo(_sortKey(b.path)));
  return files;
}

String _sortKey(String path) {
  final name = path.split(Platform.pathSeparator).last.toLowerCase();
  if (name.startsWith('cover.')) {
    return '0_$name';
  }
  final base = name.split('.').first;
  final index = int.tryParse(base);
  if (index != null) {
    return '1_${index.toString().padLeft(3, '0')}';
  }
  return '2_$name';
}

String _nextFileName(Directory folder, String imageUrl) {
  final extension = _fileExtensionFromUrl(imageUrl);
  final files = _listLocalImages(folder);
  final hasCover = files.any(
    (file) => file.path.split(Platform.pathSeparator).last.startsWith('cover.'),
  );
  if (!hasCover) {
    return 'cover$extension';
  }

  var nextIndex = 1;
  final usedNumbers = files
      .map((file) => file.path.split(Platform.pathSeparator).last.split('.').first)
      .map(int.tryParse)
      .whereType<int>()
      .toSet();
  while (usedNumbers.contains(nextIndex)) {
    nextIndex++;
  }
  return '$nextIndex$extension';
}

Future<List<CommonsImageResult>> _searchCommonsImages(
  HttpClient client,
  String query,
) async {
  final uri = Uri.parse(
    'https://commons.wikimedia.org/w/api.php?action=query&generator=search&format=json&gsrnamespace=6&gsrlimit=8&prop=imageinfo&iiprop=url&gsrsearch=${Uri.encodeQueryComponent(query)}',
  );
  final json = await _getJson(client, uri);
  final queryData = json?['query'];
  if (queryData is! Map<String, dynamic>) {
    return const [];
  }
  final pages = queryData['pages'];
  if (pages is! Map<String, dynamic>) {
    return const [];
  }

  final items = pages.values
      .whereType<Map<String, dynamic>>()
      .toList()
    ..sort((a, b) {
      final left = (a['index'] as num?)?.toInt() ?? 9999;
      final right = (b['index'] as num?)?.toInt() ?? 9999;
      return left.compareTo(right);
    });

  final results = <CommonsImageResult>[];
  for (final item in items) {
    final title = item['title']?.toString();
    final imageInfo = item['imageinfo'];
    if (title == null || imageInfo is! List || imageInfo.isEmpty) {
      continue;
    }
    final info = imageInfo.first;
    if (info is! Map<String, dynamic>) {
      continue;
    }
    final imageUrl = info['url']?.toString();
    if (imageUrl == null || imageUrl.trim().isEmpty) {
      continue;
    }
    results.add(
      CommonsImageResult(
        title: title,
        pageUrl: 'https://commons.wikimedia.org/wiki/${Uri.encodeComponent(title.replaceAll(' ', '_'))}',
        imageUrl: imageUrl.trim(),
      ),
    );
  }
  return results;
}

CommonsImageResult _manualCommonsResult(String fileTitle) {
  if (fileTitle.startsWith('http://') || fileTitle.startsWith('https://')) {
    final uri = Uri.parse(fileTitle);
    final normalizedTitle = Uri.decodeComponent(uri.pathSegments.last);
    return CommonsImageResult(
      title: 'File:$normalizedTitle',
      pageUrl:
          'https://commons.wikimedia.org/wiki/File%3A${Uri.encodeComponent(normalizedTitle)}',
      imageUrl: fileTitle,
    );
  }

  final normalizedTitle = fileTitle.startsWith('File:')
      ? fileTitle.substring(5)
      : fileTitle;
  return CommonsImageResult(
    title: 'File:$normalizedTitle',
    pageUrl:
        'https://commons.wikimedia.org/wiki/File%3A${Uri.encodeComponent(normalizedTitle)}',
    imageUrl:
        'https://commons.wikimedia.org/wiki/Special:FilePath/${Uri.encodeComponent(normalizedTitle)}',
  );
}

Future<CommonsImageResult?> _fetchWikipediaSummaryImage(
  HttpClient client,
  String title,
) async {
  final uri = Uri.parse(
    'https://en.wikipedia.org/api/rest_v1/page/summary/${Uri.encodeComponent(title)}',
  );
  final json = await _getJson(client, uri);
  if (json == null) {
    return null;
  }

  final original = json['originalimage'];
  final thumbnail = json['thumbnail'];
  String? imageUrl;
  if (original is Map<String, dynamic>) {
    imageUrl = original['source']?.toString();
  }
  imageUrl ??= thumbnail is Map<String, dynamic>
      ? thumbnail['source']?.toString()
      : null;
  if (imageUrl == null || imageUrl.trim().isEmpty) {
    return null;
  }

  final pageTitle = json['title']?.toString().trim();
  final resolvedTitle = pageTitle == null || pageTitle.isEmpty ? title : pageTitle;
  return CommonsImageResult(
    title: resolvedTitle,
    pageUrl:
        'https://en.wikipedia.org/wiki/${Uri.encodeComponent(resolvedTitle.replaceAll(' ', '_'))}',
    imageUrl: imageUrl.trim(),
  );
}

bool _shouldSkipTitle(String title) {
  final value = title.toLowerCase();
  const blocked = <String>[
    'map',
    'locator',
    'logo',
    'flag',
    'symbol',
    'coat of arms',
    'emblem',
    'diagram',
    'plan',
    'route',
    'svg',
  ];
  return blocked.any(value.contains);
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
  if (path.endsWith('.png')) {
    return '.png';
  }
  if (path.endsWith('.webp')) {
    return '.webp';
  }
  if (path.endsWith('.jpeg')) {
    return '.jpeg';
  }
  return '.jpg';
}

String _buildPhotoDataDart(List<PlaceImageSpec> specs) {
  final buffer = StringBuffer();
  final coverAssets = <String, String>{};
  final galleryAssets = <String, List<String>>{};

  for (final spec in specs) {
    final folder = Directory('assets/places/${spec.folder}');
    final files = _listLocalImages(folder);
    if (files.isEmpty) {
      continue;
    }
    final assetPaths = files
        .map((file) => file.path.replaceAll('\\', '/'))
        .toList();
    galleryAssets[spec.name] = assetPaths;
    coverAssets[spec.name] = assetPaths.first;
  }

  buffer.writeln('const Map<String, String> wikipediaPlaceTitles = {');
  for (final spec in specs) {
    buffer.writeln(
      "  '${_escape(spec.name)}': '${_escape(spec.wikipediaTitle)}',",
    );
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

void _appendAttribution(Map<String, List<CommonsImageResult>> entries) {
  if (entries.isEmpty) {
    return;
  }

  final file = File('assets/places/ATTRIBUTION.md');
  final buffer = StringBuffer();
  if (file.existsSync()) {
    buffer.write(file.readAsStringSync());
    if (!buffer.toString().endsWith('\n')) {
      buffer.writeln();
    }
  } else {
    buffer
      ..writeln('# Place Image Sources')
      ..writeln()
      ..writeln('Downloaded from free-license Wikimedia Commons images.')
      ..writeln();
  }

  for (final entry in entries.entries) {
    buffer.writeln('## ${entry.key} (Additional Commons downloads)');
    for (final image in entry.value) {
      buffer.writeln('- ${image.title}: ${image.pageUrl}');
      buffer.writeln('  - Image: ${image.imageUrl}');
    }
    buffer.writeln();
  }

  file.writeAsStringSync(buffer.toString(), flush: true);
}

String _escape(String value) {
  return value.replaceAll(r'\', r'\\').replaceAll("'", r"\'");
}
