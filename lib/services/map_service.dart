import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../data/places_data.dart';
import '../models/place_model.dart';
import 'network_service.dart';

enum MapTravelMode {
  driving,
  walking,
}

class MapSearchResult {
  final String title;
  final String subtitle;
  final double latitude;
  final double longitude;
  final bool isKnownPlace;

  const MapSearchResult({
    required this.title,
    required this.subtitle,
    required this.latitude,
    required this.longitude,
    required this.isKnownPlace,
  });
}

class MapRouteResult {
  final List<LatLng> points;
  final double distanceKm;
  final Duration duration;

  const MapRouteResult({
    required this.points,
    required this.distanceKm,
    required this.duration,
  });
}

class MapService {
  static final Map<String, Future<List<MapSearchResult>>> _searchCache = {};
  static final Map<String, Future<MapRouteResult?>> _routeCache = {};

  static Future<List<MapSearchResult>> searchLocations(String query) {
    final normalized = _normalize(query);
    if (normalized.isEmpty) {
      return Future.value(const []);
    }
    return _searchCache.putIfAbsent(
      normalized,
      () => _searchLocationsInternal(query),
    );
  }

  static Future<List<MapSearchResult>> _searchLocationsInternal(
    String query,
  ) async {
    final normalized = _normalize(query);
    final results = <MapSearchResult>[];
    final seen = <String>{};

    for (final place in seedPlaces) {
      final haystack = [
        place.name,
        place.description,
        place.type,
      ].join(" ").toLowerCase();

      if (!haystack.contains(normalized)) {
        continue;
      }

      final result = MapSearchResult(
        title: place.name,
        subtitle: "${place.type} - highlighted destination",
        latitude: place.lat,
        longitude: place.lng,
        isKnownPlace: true,
      );
      final key = _normalize(result.title);
      if (seen.add(key)) {
        results.add(result);
      }
    }

    final isOnline = await NetworkService.isOnline();
    if (!isOnline) {
      return results.take(8).toList();
    }

    try {
      final uri = Uri.parse(
        "https://nominatim.openstreetmap.org/search?format=jsonv2&countrycodes=lk&limit=6&q=${Uri.encodeQueryComponent(query)}",
      );
      final response = await http.get(
        uri,
        headers: const {
          "Accept": "application/json",
          "User-Agent": "tourist-guide-app/1.0",
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          for (final item in data) {
            if (item is! Map<String, dynamic>) {
              continue;
            }

            final title = (item["name"]?.toString().trim().isNotEmpty ?? false)
                ? item["name"].toString().trim()
                : (item["display_name"]?.toString().split(',').first.trim() ??
                    "");
            final subtitle = item["display_name"]?.toString().trim() ?? "";
            final latitude = double.tryParse(item["lat"]?.toString() ?? "");
            final longitude = double.tryParse(item["lon"]?.toString() ?? "");

            if (title.isEmpty || latitude == null || longitude == null) {
              continue;
            }

            final key = _normalize(title);
            if (!seen.add(key)) {
              continue;
            }

            results.add(
              MapSearchResult(
                title: title,
                subtitle: subtitle,
                latitude: latitude,
                longitude: longitude,
                isKnownPlace: seedPlaces.any(
                  (place) => _normalize(place.name) == key,
                ),
              ),
            );
          }
        }
      }
    } catch (_) {}

    return results.take(8).toList();
  }

  static Future<MapRouteResult?> fetchRoute({
    required LatLng start,
    required LatLng end,
    required MapTravelMode mode,
  }) {
    final key = [
      mode.name,
      start.latitude.toStringAsFixed(5),
      start.longitude.toStringAsFixed(5),
      end.latitude.toStringAsFixed(5),
      end.longitude.toStringAsFixed(5),
    ].join("|");

    return _routeCache.putIfAbsent(
      key,
      () => _fetchRouteInternal(start: start, end: end, mode: mode),
    );
  }

  static Future<MapRouteResult?> _fetchRouteInternal({
    required LatLng start,
    required LatLng end,
    required MapTravelMode mode,
  }) async {
    final isOnline = await NetworkService.isOnline();
    if (!isOnline) {
      return null;
    }

    final profile = mode == MapTravelMode.walking ? "foot" : "driving";
    final uri = Uri.parse(
      "https://router.project-osrm.org/route/v1/$profile/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson",
    );

    try {
      final response = await http.get(
        uri,
        headers: const {
          "Accept": "application/json",
          "User-Agent": "tourist-guide-app/1.0",
        },
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode != 200) {
        return null;
      }

      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic>) {
        return null;
      }

      final routes = data["routes"];
      if (routes is! List || routes.isEmpty || routes.first is! Map) {
        return null;
      }

      final firstRoute = routes.first as Map;
      final geometry = firstRoute["geometry"];
      final coordinates = geometry is Map ? geometry["coordinates"] : null;
      if (coordinates is! List || coordinates.isEmpty) {
        return null;
      }

      final points = <LatLng>[];
      for (final point in coordinates) {
        if (point is! List || point.length < 2) {
          continue;
        }
        final lon = (point[0] as num?)?.toDouble();
        final lat = (point[1] as num?)?.toDouble();
        if (lat == null || lon == null) {
          continue;
        }
        points.add(LatLng(lat, lon));
      }

      if (points.isEmpty) {
        return null;
      }

      final distanceMeters = (firstRoute["distance"] as num?)?.toDouble() ?? 0;
      final durationSeconds = (firstRoute["duration"] as num?)?.toDouble() ?? 0;

      return MapRouteResult(
        points: points,
        distanceKm: distanceMeters / 1000,
        duration: Duration(seconds: durationSeconds.round()),
      );
    } catch (_) {
      return null;
    }
  }

  static PlaceModel toPlaceModel(MapSearchResult result) {
    for (final place in seedPlaces) {
      if (_normalize(place.name) == _normalize(result.title)) {
        return place;
      }
    }

    return PlaceModel(
      name: result.title,
      description: result.subtitle.isEmpty
          ? "Searched location in Sri Lanka."
          : result.subtitle,
      image: "assets/places/galle/cover.png",
      lat: result.latitude,
      lng: result.longitude,
      type: "Search",
    );
  }

  static String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
