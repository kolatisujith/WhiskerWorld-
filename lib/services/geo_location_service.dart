import 'dart:math' as math;
import 'package:latlong2/latlong.dart';

/// Geographic location and distance utility for Pet Stores, Pet Owners, and Pets.
class GeoLocationService {
  GeoLocationService._();

  /// Reference coordinates for popular US & global cities
  static final Map<String, LatLng> _knownCityCoordinates = {
    'portland': const LatLng(45.5152, -122.6784),
    'seattle': const LatLng(47.6062, -122.3321),
    'austin': const LatLng(30.2672, -97.7431),
    'san francisco': const LatLng(37.7749, -122.4194),
    'los angeles': const LatLng(34.0522, -118.2437),
    'san diego': const LatLng(32.7157, -117.1611),
    'chicago': const LatLng(41.8781, -87.6298),
    'new york': const LatLng(40.7128, -74.0060),
    'boston': const LatLng(42.3601, -71.0589),
    'denver': const LatLng(39.7392, -104.9903),
    'phoenix': const LatLng(33.4484, -112.0740),
    'dallas': const LatLng(32.7767, -96.7970),
    'houston': const LatLng(29.7604, -95.3698),
    'miami': const LatLng(25.7617, -80.1918),
    'atlanta': const LatLng(33.7490, -84.3880),
    'orlando': const LatLng(28.5383, -81.3792),
    'las vegas': const LatLng(36.1699, -115.1398),
    'salt lake city': const LatLng(40.7608, -111.8910),
  };

  /// Default fallback coordinate (Whisker World headquarters - Portland, OR)
  static const LatLng defaultLocation = LatLng(45.5152, -122.6784);

  /// Resolves geographic coordinate for an entity.
  /// If [explicitLat] and [explicitLng] are non-null, returns them directly.
  /// Otherwise looks up city/address keywords, with fallback to default.
  /// Optional [entityId] adds deterministic micro-dispersion so coincident pins don't overlap.
  static LatLng resolveCoordinates({
    double? explicitLat,
    double? explicitLng,
    String? city,
    String? address,
    String? fullLocation,
    String? entityId,
    int? indexHint,
  }) {
    LatLng baseCoord;

    if (explicitLat != null && explicitLng != null && (explicitLat != 0.0 || explicitLng != 0.0)) {
      baseCoord = LatLng(explicitLat, explicitLng);
    } else {
      baseCoord = _lookupFromText(city) ??
          _lookupFromText(fullLocation) ??
          _lookupFromText(address) ??
          defaultLocation;
    }

    // If explicit coordinates were given, keep them exact.
    if (explicitLat != null && explicitLng != null) {
      return baseCoord;
    }

    // Otherwise apply deterministic micro-dispersion (jitter) if entityId or indexHint is provided
    if (entityId != null || indexHint != null) {
      return applyDeterministicJitter(baseCoord, entityId: entityId, indexHint: indexHint);
    }

    return baseCoord;
  }

  static LatLng? _lookupFromText(String? text) {
    if (text == null || text.trim().isEmpty) return null;
    final lower = text.toLowerCase();

    for (final entry in _knownCityCoordinates.entries) {
      if (lower.contains(entry.key)) {
        return entry.value;
      }
    }
    return null;
  }

  /// Applies a small deterministic offset to prevent pins in the same city from exactly stacking on top of each other.
  static LatLng applyDeterministicJitter(
    LatLng base, {
    String? entityId,
    int? indexHint,
  }) {
    int seed = 0;
    if (entityId != null) {
      for (final char in entityId.codeUnits) {
        seed = (seed * 31 + char) & 0x7FFFFFFF;
      }
    }
    if (indexHint != null) {
      seed += indexHint * 1013;
    }

    // Radius between 0.003 and 0.012 degrees (~300m - 1.3km)
    final radius = 0.004 + ((seed % 100) / 100.0) * 0.008;
    // Angle 0 to 2*PI
    final angle = ((seed % 360) / 360.0) * 2 * math.pi;

    final latOffset = radius * math.sin(angle);
    final lngOffset = radius * math.cos(angle);

    return LatLng(base.latitude + latOffset, base.longitude + lngOffset);
  }

  /// Calculates great-circle distance between two points using the Haversine formula in miles.
  static double calculateDistanceMiles(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadiusMiles = 3958.8; // Radius of the Earth in miles
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusMiles * c;
  }

  /// Calculates distance in kilometers.
  static double calculateDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return calculateDistanceMiles(lat1, lon1, lat2, lon2) * 1.60934;
  }

  /// Formats distance human-readably (e.g. "0.8 miles away" or "15 miles away")
  static String formatDistance(double miles) {
    if (miles < 0.1) {
      return 'Less than 0.1 miles away';
    } else if (miles < 10) {
      return '${miles.toStringAsFixed(1)} miles away';
    } else {
      return '${miles.toStringAsFixed(0)} miles away';
    }
  }

  static double _toRadians(double degree) => degree * (math.pi / 180.0);
}
