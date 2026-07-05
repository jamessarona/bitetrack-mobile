import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Resolves user location quickly: last known first, then fresh GPS.
class DiscoverLocationReader {
  const DiscoverLocationReader._();

  static Future<bool> ensurePermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return false;
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Returns immediately with last known position when available.
  static Future<LatLng?> readLastKnown() async {
    final last = await Geolocator.getLastKnownPosition();
    if (last == null) return null;
    return LatLng(last.latitude, last.longitude);
  }

  static Future<LatLng> readBestPosition() async {
    final last = await readLastKnown();
    try {
      final fresh = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
      return LatLng(fresh.latitude, fresh.longitude);
    } catch (_) {
      if (last != null) return last;
      rethrow;
    }
  }
}
