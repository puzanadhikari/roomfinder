import 'dart:math';

double haversineDistance(double lat1, double lon1, double lat2, double lon2) {
  const earthRadius = 6371; // Radius of the Earth in kilometers

  double dLat = _toRadians(lat2 - lat1);
  double dLon = _toRadians(lon2 - lon1);

  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
          sin(dLon / 2) * sin(dLon / 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return earthRadius * c; // Distance in kilometers
}

double _toRadians(double degrees) {
  return degrees * pi / 180;
}
