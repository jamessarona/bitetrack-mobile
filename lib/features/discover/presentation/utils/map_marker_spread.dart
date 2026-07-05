import 'dart:math' as math;

import 'package:latlong2/latlong.dart';
import 'package:bitetrack/features/business/domain/entities/business.dart';

const _clusterPrecision = 5;
const _sameSpotThresholdMeters = 12.0;
const _spreadRadiusMeters = 22.0;

String _locationKey(double lat, double lng) {
  return '${lat.toStringAsFixed(_clusterPrecision)}:${lng.toStringAsFixed(_clusterPrecision)}';
}

double _distanceMeters(LatLng a, LatLng b) {
  const earthRadius = 6371000.0;
  final dLat = _toRadians(b.latitude - a.latitude);
  final dLng = _toRadians(b.longitude - a.longitude);
  final lat1 = _toRadians(a.latitude);
  final lat2 = _toRadians(b.latitude);
  final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(lat1) * math.cos(lat2) * math.sin(dLng / 2) * math.sin(dLng / 2);
  return earthRadius * 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
}

double _toRadians(double deg) => deg * math.pi / 180;

LatLng spreadAround(LatLng center, int index, int total, {double radiusMeters = _spreadRadiusMeters}) {
  if (total <= 1) return center;

  final angle = (2 * math.pi * index) / total - math.pi / 2;
  final latOffset = (radiusMeters / 111111) * math.cos(angle);
  final lngScale = math.cos(center.latitude * math.pi / 180).abs().clamp(0.2, 1.0);
  final lngOffset = (radiusMeters / (111111 * lngScale)) * math.sin(angle);

  return LatLng(center.latitude + latOffset, center.longitude + lngOffset);
}

class BusinessMarkerPlacement {
  const BusinessMarkerPlacement({
    required this.business,
    required this.displayPoint,
    required this.clusterSize,
  });

  final Business business;
  final LatLng displayPoint;
  final int clusterSize;
}

class UserMarkerPlacement {
  const UserMarkerPlacement({required this.displayPoint, required this.clusterSize});

  final LatLng displayPoint;
  final int clusterSize;
}

({UserMarkerPlacement? user, List<BusinessMarkerPlacement> businesses}) layoutMapMarkers({
  required LatLng? userLocation,
  required List<Business> businesses,
}) {
  final withCoords = businesses.where((b) => b.latitude != null && b.longitude != null).toList();
  if (withCoords.isEmpty && userLocation == null) {
    return (user: null, businesses: []);
  }

  final clusters = <String, List<Business>>{};
  for (final business in withCoords) {
    final key = _locationKey(business.latitude!, business.longitude!);
    clusters.putIfAbsent(key, () => []).add(business);
  }

  UserMarkerPlacement? userPlacement;
  final businessPlacements = <BusinessMarkerPlacement>[];

  if (userLocation != null) {
    final userKey = _locationKey(userLocation.latitude, userLocation.longitude);
    final userCluster = clusters[userKey];

    if (userCluster != null) {
      final total = userCluster.length + 1;
      userPlacement = UserMarkerPlacement(
        displayPoint: spreadAround(userLocation, 0, total),
        clusterSize: total,
      );
      for (var i = 0; i < userCluster.length; i++) {
        businessPlacements.add(
          BusinessMarkerPlacement(
            business: userCluster[i],
            displayPoint: spreadAround(userLocation, i + 1, total),
            clusterSize: total,
          ),
        );
      }
      clusters.remove(userKey);
    } else {
      for (final entry in clusters.entries.toList()) {
        final center = LatLng(entry.value.first.latitude!, entry.value.first.longitude!);
        if (_distanceMeters(userLocation, center) <= _sameSpotThresholdMeters) {
          final total = entry.value.length + 1;
          userPlacement = UserMarkerPlacement(
            displayPoint: spreadAround(center, 0, total),
            clusterSize: total,
          );
          for (var i = 0; i < entry.value.length; i++) {
            businessPlacements.add(
              BusinessMarkerPlacement(
                business: entry.value[i],
                displayPoint: spreadAround(center, i + 1, total),
                clusterSize: total,
              ),
            );
          }
          clusters.remove(entry.key);
          break;
        }
      }
      userPlacement ??= UserMarkerPlacement(displayPoint: userLocation, clusterSize: 1);
    }
  }

  for (final cluster in clusters.values) {
    final center = LatLng(cluster.first.latitude!, cluster.first.longitude!);
    final total = cluster.length;
    for (var i = 0; i < cluster.length; i++) {
      businessPlacements.add(
        BusinessMarkerPlacement(
          business: cluster[i],
          displayPoint: spreadAround(center, i, total),
          clusterSize: total,
        ),
      );
    }
  }

  return (user: userPlacement, businesses: businessPlacements);
}
