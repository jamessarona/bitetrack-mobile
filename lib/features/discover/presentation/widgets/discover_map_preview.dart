import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:bitetrack/features/business/domain/entities/business.dart';
import 'package:bitetrack/features/discover/presentation/widgets/map_markers.dart';
import 'package:bitetrack/features/discover/presentation/utils/map_marker_spread.dart';

/// Embedded map preview for Discover home — shows current area and nearby pins.
class DiscoverMapPreview extends StatelessWidget {
  const DiscoverMapPreview({
    super.key,
    required this.center,
    required this.businesses,
    required this.userLocation,
    required this.onTap,
    required this.isDark,
  });

  final LatLng center;
  final LatLng? userLocation;
  final List<Business> businesses;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final layout = layoutMapMarkers(userLocation: userLocation, businesses: businesses);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 180,
          child: Stack(
            fit: StackFit.expand,
            children: [
              IgnorePointer(
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: 14,
                    interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.bitetrack.app',
                    ),
                    if (layout.user != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: layout.user!.displayPoint,
                            width: UserMapMarker.markerWidth,
                            height: UserMapMarker.markerHeight,
                            alignment: Alignment.center,
                            child: const UserMapMarker(clusterSize: 1),
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: layout.businesses
                          .take(8)
                          .map(
                            (p) => Marker(
                              point: p.displayPoint,
                              width: 28,
                              height: 28,
                              alignment: Alignment.center,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.white, width: 1.5),
                                ),
                                child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 14),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colorScheme.outlineVariant),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.map_rounded, color: colorScheme.primary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          businesses.isEmpty
                              ? 'Open live map near you'
                              : '${businesses.length} live ${businesses.length == 1 ? 'vendor' : 'vendors'} on map',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, size: 14, color: colorScheme.primary),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
