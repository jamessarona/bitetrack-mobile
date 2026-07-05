import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:bitetrack/features/business/data/repositories/business_repository.dart';

/// Keeps location pings running while a business is live, even when the user
/// navigates away from the business detail screen.
@lazySingleton
class LiveSellingLocationService {
  LiveSellingLocationService(this._repository);

  final BusinessRepository _repository;
  Timer? _timer;
  String? _activeBusinessId;

  static const _pingInterval = Duration(seconds: 10);

  String? get activeBusinessId => _activeBusinessId;

  bool isTracking(String businessId) =>
      _activeBusinessId == businessId && _timer != null;

  void start(String businessId) {
    if (_activeBusinessId == businessId && _timer != null) return;
    stop();
    _activeBusinessId = businessId;
    unawaited(_ping());
    _timer = Timer.periodic(_pingInterval, (_) => unawaited(_ping()));
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _activeBusinessId = null;
  }

  Future<void> _ping() async {
    final businessId = _activeBusinessId;
    if (businessId == null) return;

    try {
      final permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      await _repository.updateSellingLocation(
        businessId: businessId,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (_) {
      // Silent retry on next interval — seller may be moving through a dead zone.
    }
  }
}
