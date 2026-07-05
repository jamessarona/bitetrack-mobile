import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';
import 'package:bitetrack/features/business/domain/entities/business.dart';

/// In-memory cache so Discover home and full map open instantly at the last known area.
@lazySingleton
class DiscoverMapCache {
  LatLng? lastCenter;
  List<Business> lastBusinesses = [];
  Map<String, String> lastCategoryNames = {};

  void update({
    required LatLng center,
    required List<Business> businesses,
    required Map<String, String> categoryNames,
  }) {
    lastCenter = center;
    lastBusinesses = List.unmodifiable(businesses);
    lastCategoryNames = Map.unmodifiable(categoryNames);
  }

  void clear() {
    lastCenter = null;
    lastBusinesses = [];
    lastCategoryNames = {};
  }
}

/// Default fallback when no location is available yet (Manila).
const kDiscoverMapFallback = LatLng(14.5995, 120.9842);
