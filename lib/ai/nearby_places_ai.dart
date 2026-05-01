import 'dart:math';

class NearbyPlacesAI {
  static double _degToRad(double deg) => deg * (pi / 180);

  static double distanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    return earthRadius * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  static List<Map<String, dynamic>> getNearby({
    required double lat,
    required double lon,
    required List<Map<String, dynamic>> places,
    double radiusKm = 120,
  }) {
    return places.where((p) {
      final d = distanceKm(lat, lon, p['lat'], p['lon']);
      return d <= radiusKm;
    }).toList();
  }
}
