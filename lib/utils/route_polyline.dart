import 'package:latlong2/latlong.dart';

class RoutePolyline {
  static List<LatLng> simpleRoute(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return [
      LatLng(startLat, startLng),
      LatLng(endLat, endLng),
    ];
  }
}
