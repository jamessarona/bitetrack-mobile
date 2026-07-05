import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:bitetrack/core/di/injection.dart';
import 'package:bitetrack/core/error/failures.dart';
import 'package:bitetrack/core/theme/app_colors.dart';
import 'package:bitetrack/features/business/data/repositories/business_repository.dart';
import 'package:bitetrack/features/business/domain/entities/business.dart';
import 'package:bitetrack/features/business/presentation/widgets/seller_status_banner.dart';
import 'package:bitetrack/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bitetrack/features/discover/data/discover_location_reader.dart';
import 'package:bitetrack/features/discover/data/discover_map_cache.dart';
import 'package:bitetrack/features/discover/presentation/utils/map_marker_spread.dart';
import 'package:bitetrack/features/discover/presentation/widgets/map_markers.dart';
import 'package:bitetrack/features/discover/presentation/widgets/nearby_business_sheet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DiscoverMapPage extends StatefulWidget {
  const DiscoverMapPage({super.key});

  @override
  State<DiscoverMapPage> createState() => _DiscoverMapPageState();
}

class _DiscoverMapPageState extends State<DiscoverMapPage> {
  final _repository = getIt<BusinessRepository>();
  final _cache = getIt<DiscoverMapCache>();
  final _mapController = MapController();

  late LatLng _mapCenter;
  LatLng? _userLocation;
  List<Business> _nearbyBusinesses = [];
  Map<String, String> _categoryNames = {};
  String? _selectedBusinessId;
  bool _refreshing = false;
  String? _bannerMessage;

  @override
  void initState() {
    super.initState();
    _hydrateFromCache();
    _bootstrap();
  }

  void _hydrateFromCache() {
    _mapCenter = _cache.lastCenter ?? kDiscoverMapFallback;
    _userLocation = _cache.lastCenter;
    _nearbyBusinesses = List.from(_cache.lastBusinesses);
    _categoryNames = Map.from(_cache.lastCategoryNames);
  }

  Future<void> _bootstrap() async {
    final lastKnown = await DiscoverLocationReader.readLastKnown();
    if (lastKnown != null && mounted) {
      setState(() {
        _mapCenter = lastKnown;
        _userLocation = lastKnown;
      });
      _moveMapWhenReady(lastKnown);
    }
    await _refreshNearby();
  }

  Future<void> _refreshNearby() async {
    if (!mounted) return;
    setState(() {
      _refreshing = true;
      _bannerMessage = null;
    });

    try {
      final permission = await DiscoverLocationReader.ensurePermission();
      if (!permission) {
        if (!mounted) return;
        setState(() {
          _refreshing = false;
          _bannerMessage = 'Location permission is required to find nearby vendors.';
        });
        return;
      }

      final userPoint = await DiscoverLocationReader.readBestPosition();

      final results = await Future.wait([
        _repository.listNearbyBusinesses(
          latitude: userPoint.latitude,
          longitude: userPoint.longitude,
        ),
        _repository.listCategories(),
      ]);

      final businesses = results[0] as List<Business>;
      final categories = results[1] as List<Category>;
      final categoryNames = {for (final c in categories) c.id: c.name};

      _cache.update(
        center: userPoint,
        businesses: businesses,
        categoryNames: categoryNames,
      );

      if (!mounted) return;
      setState(() {
        _mapCenter = userPoint;
        _userLocation = userPoint;
        _nearbyBusinesses = businesses;
        _categoryNames = categoryNames;
        _refreshing = false;
      });

      _moveMapWhenReady(userPoint);
    } on Failure catch (e) {
      if (!mounted) return;
      setState(() {
        _refreshing = false;
        _bannerMessage = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _refreshing = false;
        _bannerMessage = 'Could not refresh nearby vendors. Pull refresh to try again.';
      });
    }
  }

  void _moveMapWhenReady(LatLng point, {double? zoom}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        final targetZoom = zoom ?? _mapController.camera.zoom;
        _mapController.move(point, targetZoom);
      } catch (_) {}
    });
  }

  void _selectBusiness(Business business, {LatLng? focusPoint, bool panToBusiness = false}) {
    setState(() => _selectedBusinessId = business.id);
    if (!panToBusiness || focusPoint == null) return;
    _moveMapWhenReady(focusPoint);
  }

  void _centerOnBusiness(Business business, {LatLng? focusPoint}) {
    if (focusPoint == null) {
      if (business.latitude == null || business.longitude == null) return;
      focusPoint = LatLng(business.latitude!, business.longitude!);
    }
    setState(() => _selectedBusinessId = business.id);
    _moveMapWhenReady(focusPoint);
  }

  void _centerOnUser() {
    if (_userLocation == null) return;
    _moveMapWhenReady(_userLocation!, zoom: 14);
  }

  LatLng? _displayPointFor(Business business, List<BusinessMarkerPlacement> placements) {
    for (final placement in placements) {
      if (placement.business.id == business.id) {
        return placement.displayPoint;
      }
    }
    if (business.latitude == null || business.longitude == null) return null;
    return LatLng(business.latitude!, business.longitude!);
  }

  void _backToDiscover() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  void _openBusinessSheet(
    Business business, {
    LatLng? focusPoint,
    bool panToBusiness = false,
  }) {
    _selectBusiness(business, focusPoint: focusPoint, panToBusiness: panToBusiness);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NearbyBusinessSheet(
        business: business,
        categoryName: categoryNameFor(_categoryNames, business.categoryId),
        onCenterOnMap: () {
          Navigator.pop(context);
          _centerOnBusiness(business, focusPoint: focusPoint);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthBloc>().state;
    final showSellerBanner = user is AuthAuthenticated && user.user.hasBusinesses;
    final colorScheme = Theme.of(context).colorScheme;
    final layout = layoutMapMarkers(
      userLocation: _userLocation,
      businesses: _nearbyBusinesses,
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _mapCenter,
            initialZoom: 14,
            interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
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
                    child: UserMapMarker(clusterSize: layout.user!.clusterSize),
                  ),
                ],
              ),
            MarkerLayer(
              markers: layout.businesses
                  .map(
                    (placement) => Marker(
                      point: placement.displayPoint,
                      width: BusinessMapMarker.markerWidth,
                      height: BusinessMapMarker.markerHeight,
                      alignment: Alignment.bottomCenter,
                      child: BusinessMapMarker(
                        business: placement.business,
                        selected: _selectedBusinessId == placement.business.id,
                        clusterSize: placement.clusterSize,
                        onTap: () => _openBusinessSheet(
                          placement.business,
                          focusPoint: placement.displayPoint,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: _MapTopBar(
                  count: _nearbyBusinesses.length,
                  refreshing: _refreshing,
                  onBack: _backToDiscover,
                  onRefresh: _refreshNearby,
                ),
              ),
              if (showSellerBanner)
                const Padding(
                  padding: EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: SellerStatusBanner(),
                ),
            ],
          ),
        ),
        Positioned(
          right: 16,
          bottom: _nearbyBusinesses.isEmpty ? 24 : 200,
          child: Column(
            children: [
              _MapFab(
                icon: Icons.my_location_rounded,
                tooltip: 'My location',
                onPressed: _centerOnUser,
              ),
              const SizedBox(height: 10),
              _MapFab(
                icon: Icons.refresh_rounded,
                tooltip: 'Refresh',
                onPressed: _refreshNearby,
              ),
            ],
          ),
        ),
        if (_bannerMessage != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: _nearbyBusinesses.isEmpty ? 24 : 200,
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(12),
              color: colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: colorScheme.onErrorContainer),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _bannerMessage!,
                        style: TextStyle(color: colorScheme.onErrorContainer, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else if (_nearbyBusinesses.isNotEmpty)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _NearbyCarousel(
              businesses: _nearbyBusinesses,
              categoryNames: _categoryNames,
              selectedId: _selectedBusinessId,
              onBusinessTap: (business) => _openBusinessSheet(
                business,
                focusPoint: _displayPointFor(business, layout.businesses),
                panToBusiness: true,
              ),
            ),
          )
        else if (!_refreshing)
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.radar_rounded, color: colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No live businesses nearby yet. Check back when vendors go live on the map.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _MapTopBar extends StatelessWidget {
  const _MapTopBar({
    required this.count,
    required this.refreshing,
    required this.onBack,
    required this.onRefresh,
  });

  final int count;
  final bool refreshing;
  final VoidCallback onBack;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      elevation: 3,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(16),
      color: colorScheme.surface.withValues(alpha: 0.96),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          children: [
            IconButton.filledTonal(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: 'Back to Discover',
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Live map',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '$count ${count == 1 ? 'business' : 'businesses'} nearby',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                      if (refreshing)
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.primary,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: isDark ? AppDarkColors.brandGradient : AppColors.brandGradient,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.map_rounded, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'Discover',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: refreshing ? null : onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Refresh',
            ),
          ],
        ),
      ),
    );
  }
}

class _MapFab extends StatelessWidget {
  const _MapFab({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      shape: const CircleBorder(),
      color: Theme.of(context).colorScheme.surface,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Theme.of(context).colorScheme.primary),
        tooltip: tooltip,
      ),
    );
  }
}

class _NearbyCarousel extends StatelessWidget {
  const _NearbyCarousel({
    required this.businesses,
    required this.categoryNames,
    required this.selectedId,
    required this.onBusinessTap,
  });

  final List<Business> businesses;
  final Map<String, String> categoryNames;
  final String? selectedId;
  final ValueChanged<Business> onBusinessTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.surface.withValues(alpha: 0),
            colorScheme.surface.withValues(alpha: 0.92),
            colorScheme.surface,
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'Nearby now',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            SizedBox(
              height: 118,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: businesses.length,
                itemBuilder: (context, index) {
                  final business = businesses[index];
                  return NearbyBusinessCarouselCard(
                    business: business,
                    selected: selectedId == business.id,
                    categoryName: categoryNameFor(categoryNames, business.categoryId),
                    onTap: () => onBusinessTap(business),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
