import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bitetrack/core/di/injection.dart';
import 'package:bitetrack/core/error/failures.dart';
import 'package:bitetrack/features/business/data/repositories/business_repository.dart';
import 'package:bitetrack/features/business/data/services/live_selling_location_service.dart';
import 'package:bitetrack/features/business/domain/entities/business.dart';

/// Discover/home banner for users who own businesses — live status or quick go-live entry.
class SellerStatusBanner extends StatefulWidget {
  const SellerStatusBanner({super.key});

  @override
  State<SellerStatusBanner> createState() => SellerStatusBannerState();
}

class SellerStatusBannerState extends State<SellerStatusBanner> {
  final _repository = getIt<BusinessRepository>();
  final _locationService = getIt<LiveSellingLocationService>();

  List<Business> _businesses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => _loading = true);
    try {
      final businesses = await _repository.listMyBusinesses();
      if (!mounted) return;

      final live = businesses.where((b) => b.isLive).toList();
      if (live.isNotEmpty) {
        _locationService.start(live.first.id);
      } else {
        _locationService.stop();
      }

      setState(() {
        _businesses = businesses;
        _loading = false;
      });
    } on Failure {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _openBusiness(Business business) async {
    final updated = await context.push<bool>(
      '/businesses/${business.id}',
      extra: business,
    );
    if (updated == true) {
      await load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: LinearProgressIndicator(minHeight: 2),
      );
    }

    if (_businesses.isEmpty) return const SizedBox.shrink();

    final liveBusinesses = _businesses.where((b) => b.isLive).toList();
    if (liveBusinesses.isNotEmpty) {
      return _LiveBanner(
        business: liveBusinesses.first,
        liveCount: liveBusinesses.length,
        onTap: () => _openBusiness(liveBusinesses.first),
        onManage: () => context.push('/businesses'),
      );
    }

    return _GoLivePrompt(
      businesses: _businesses,
      onOpen: (business) => _openBusiness(business),
      onManage: () => context.push('/businesses'),
    );
  }
}

class _LiveBanner extends StatelessWidget {
  const _LiveBanner({
    required this.business,
    required this.liveCount,
    required this.onTap,
    required this.onManage,
  });

  final Business business;
  final int liveCount;
  final VoidCallback onTap;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.radar_rounded, color: Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const _LiveChip(),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              business.businessName,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        liveCount > 1
                            ? '$liveCount businesses live · tap to manage'
                            : 'You are live on the map · customers can find you',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.85),
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onManage,
                  icon: Icon(Icons.storefront_outlined, color: colorScheme.primary),
                  tooltip: 'My businesses',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoLivePrompt extends StatelessWidget {
  const _GoLivePrompt({
    required this.businesses,
    required this.onOpen,
    required this.onManage,
  });

  final List<Business> businesses;
  final ValueChanged<Business> onOpen;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = businesses.firstWhere(
      (b) => b.canGoLive,
      orElse: () => businesses.first,
    );
    final canGoLive = primary.canGoLive;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.storefront_outlined, color: colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Your business',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                !canGoLive
                    ? 'Your business "${primary.businessName}" needs verification before you can go live.'
                    : businesses.length == 1
                        ? 'Go live on "${primary.businessName}" so customers can find you on the map.'
                        : 'You have ${businesses.length} businesses. Open one to go live.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: canGoLive ? () => onOpen(primary) : null,
                      icon: const Icon(Icons.radar_rounded, size: 18),
                      label: const Text('Go live'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: onManage,
                    child: const Text('Manage'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveChip extends StatelessWidget {
  const _LiveChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text(
        'LIVE',
        style: TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }
}
