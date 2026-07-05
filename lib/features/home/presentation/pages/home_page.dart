import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:bitetrack/core/di/injection.dart';
import 'package:bitetrack/core/error/failures.dart';
import 'package:bitetrack/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bitetrack/features/business/data/repositories/business_repository.dart';
import 'package:bitetrack/features/business/domain/entities/business.dart';
import 'package:bitetrack/features/business/presentation/widgets/seller_status_banner.dart';
import 'package:bitetrack/features/discover/data/discover_location_reader.dart';
import 'package:bitetrack/features/discover/data/discover_map_cache.dart';
import 'package:bitetrack/features/discover/presentation/widgets/discover_skeleton.dart';
import 'package:bitetrack/features/discover/presentation/widgets/discover_map_preview.dart';
import 'package:bitetrack/features/discover/presentation/widgets/nearby_business_compact_card.dart';
import 'package:bitetrack/features/discover/presentation/widgets/nearby_business_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _repository = getIt<BusinessRepository>();
  final _cache = getIt<DiscoverMapCache>();
  final _sellerBannerKey = GlobalKey<SellerStatusBannerState>();

  List<Business> _nearbyBusinesses = [];
  List<Category> _categories = [];
  Map<String, String> _categoryNames = {};
  String? _selectedCategoryId;
  LatLng? _userLocation;
  bool _refreshing = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _hydrateFromCache();
    _loadDiscoverData();
  }

  void _hydrateFromCache() {
    if (_cache.lastCenter != null) {
      _userLocation = _cache.lastCenter;
      _nearbyBusinesses = List.from(_cache.lastBusinesses);
      _categoryNames = Map.from(_cache.lastCategoryNames);
    }
  }

  Future<void> _loadDiscoverData() async {
    setState(() {
      _refreshing = true;
      _loadError = null;
    });

    try {
      final lastKnown = await DiscoverLocationReader.readLastKnown();
      if (lastKnown != null && mounted) {
        setState(() => _userLocation = lastKnown);
      }

      final permission = await DiscoverLocationReader.ensurePermission();
      if (!permission) {
        setState(() {
          _refreshing = false;
          _loadError = 'Location permission is needed to find vendors near you.';
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
        _userLocation = userPoint;
        _nearbyBusinesses = businesses;
        _categories = categories;
        _categoryNames = categoryNames;
        _refreshing = false;
      });
    } on Failure catch (e) {
      if (!mounted) return;
      setState(() {
        _refreshing = false;
        _loadError = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _refreshing = false;
        _loadError = 'Could not load nearby vendors.';
      });
    }
  }

  Future<void> _refresh() async {
    await Future.wait([
      _loadDiscoverData(),
      if (_sellerBannerKey.currentState != null) _sellerBannerKey.currentState!.load(),
    ]);
  }

  List<Business> get _filteredBusinesses {
    if (_selectedCategoryId == null) return _nearbyBusinesses;
    return _nearbyBusinesses.where((b) => b.categoryId == _selectedCategoryId).toList();
  }

  void _openBusinessSheet(Business business) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NearbyBusinessSheet(
        business: business,
        categoryName: categoryNameFor(_categoryNames, business.categoryId),
        onCenterOnMap: () {
          Navigator.pop(context);
          context.push('/discover/map');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredBusinesses;
    final showSkeleton = _refreshing && _nearbyBusinesses.isEmpty && _categories.isEmpty && _loadError == null;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;
        final greeting = _greetingFor(DateTime.now());
        final name = user?.firstName.trim().isNotEmpty == true
            ? user!.firstName
            : user?.displayName ?? 'there';

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Text(
                '$greeting, $name',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Find mobile vendors and street food near you.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
              ),
              if (user?.hasBusinesses == true) ...[
                const SizedBox(height: 16),
                SellerStatusBanner(key: _sellerBannerKey),
              ],
              const SizedBox(height: 20),
              TextField(
                readOnly: true,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Search is coming soon')),
                  );
                },
                decoration: InputDecoration(
                  hintText: 'Search vendors, food, or area',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.tune_rounded),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (showSkeleton)
                const DiscoverMapPreviewSkeleton()
              else
                DiscoverMapPreview(
                  center: _userLocation ?? _cache.lastCenter ?? kDiscoverMapFallback,
                  userLocation: _userLocation,
                  businesses: _nearbyBusinesses,
                  isDark: isDark,
                  onTap: () => context.push('/discover/map'),
                ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    'Quick browse',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  if (!showSkeleton && _nearbyBusinesses.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Text(
                      '· ${filtered.length} nearby',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              if (showSkeleton)
                const DiscoverCategoryChipsSkeleton()
              else
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _CategoryChip(
                        label: 'All',
                        selected: _selectedCategoryId == null,
                        onSelected: () => setState(() => _selectedCategoryId = null),
                      ),
                      ..._categories.map(
                        (category) => _CategoryChip(
                          label: category.name,
                          selected: _selectedCategoryId == category.id,
                          onSelected: () => setState(() => _selectedCategoryId = category.id),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              if (showSkeleton)
                const DiscoverBusinessListSkeleton()
              else if (_loadError != null && _nearbyBusinesses.isEmpty)
                _DiscoverMessageCard(
                  icon: Icons.location_off_outlined,
                  title: 'Location needed',
                  message: _loadError!,
                  actionLabel: 'Retry',
                  onAction: _loadDiscoverData,
                )
              else if (_nearbyBusinesses.isEmpty)
                _DiscoverMessageCard(
                  icon: Icons.radar_rounded,
                  title: 'No live vendors nearby',
                  message: 'When businesses go live near you, they will show up here and on the map.',
                  actionLabel: 'Open map',
                  onAction: () => context.push('/discover/map'),
                )
              else if (filtered.isEmpty)
                _DiscoverMessageCard(
                  icon: Icons.filter_list_off_rounded,
                  title: 'No vendors in this category',
                  message: 'Try another category or open the map to see all nearby vendors.',
                  actionLabel: 'Show all',
                  onAction: () => setState(() => _selectedCategoryId = null),
                )
              else
                ...filtered.map(
                  (business) => NearbyBusinessCompactCard(
                    business: business,
                    categoryName: categoryNameFor(_categoryNames, business.categoryId),
                    onTap: () => _openBusinessSheet(business),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _greetingFor(DateTime now) {
    final hour = now.hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
        showCheckmark: false,
        selectedColor: colorScheme.primaryContainer,
        labelStyle: TextStyle(
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _DiscoverMessageCard extends StatelessWidget {
  const _DiscoverMessageCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(icon, size: 40, color: colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
