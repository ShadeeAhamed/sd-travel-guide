import 'dart:math';

class DirectionsUtils {
  static String getDirection(
      double lat1, double lon1, double lat2, double lon2) {
    final dLon = lon2 - lon1;
    final y = sin(dLon) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    final brng = atan2(y, x) * 180 / pi;

    if (brng >= -45 && brng < 45) return "Go East";
    if (brng >= 45 && brng < 135) return "Go North";
    if (brng >= -135 && brng < -45) return "Go South";
    return "Go West";
  }
}
