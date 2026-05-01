import '../models/place_model.dart';
import 'distance_utils.dart';

class NearbyPlacesHelper {
  static List<PlaceModel> getNearbyPlaces({
    required List<PlaceModel> allPlaces,
    required PlaceModel currentPlace,
    double radiusKm = 50,
  }) {
    final filtered = allPlaces
        .where((p) => p.name != currentPlace.name)
        .map((p) {
          final d = DistanceUtils.calculateDistance(
            currentPlace.lat,
            currentPlace.lng,
            p.lat,
            p.lng,
          );
          return MapEntry(p, d);
        })
        .where((e) => e.value <= radiusKm)
        .toList();

    filtered.sort((a, b) => a.value.compareTo(b.value));

    return filtered.map((e) => e.key).toList();
  }
}
