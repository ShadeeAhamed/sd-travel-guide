class ETAUtils {
  static double walkingSpeedKmH = 5;
  static double drivingSpeedKmH = 40;

  static Duration walkingETA(double distanceKm) {
    final hours = distanceKm / walkingSpeedKmH;
    return Duration(minutes: (hours * 60).round());
  }

  static Duration drivingETA(double distanceKm) {
    final hours = distanceKm / drivingSpeedKmH;
    return Duration(minutes: (hours * 60).round());
  }
}
