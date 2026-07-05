import 'package:flutter/material.dart';
import 'package:bitetrack/features/business/domain/entities/business.dart';

String formatDistanceMeters(double? meters) {
  if (meters == null) return '';
  if (meters < 1000) return '${meters.round()} m away';
  return '${(meters / 1000).toStringAsFixed(1)} km away';
}

String businessStatusLabel(BusinessStatus status) {
  return switch (status) {
    BusinessStatus.available => 'Available now',
    BusinessStatus.online => 'Online',
    BusinessStatus.onRoute => 'On the move',
    BusinessStatus.busy => 'Busy',
    BusinessStatus.offline => 'Offline',
  };
}

Color businessStatusColor(BusinessStatus status, ColorScheme scheme) {
  return switch (status) {
    BusinessStatus.available => Colors.green,
    BusinessStatus.online => scheme.primary,
    BusinessStatus.onRoute => Colors.orange,
    BusinessStatus.busy => Colors.amber.shade800,
    BusinessStatus.offline => scheme.outline,
  };
}

bool businessIsLiveOnMap(Business business) {
  return business.status != BusinessStatus.offline;
}

String? categoryNameFor(Map<String, String> categories, String? categoryId) {
  if (categoryId == null) return null;
  return categories[categoryId];
}

class NearbyBusinessSheet extends StatelessWidget {
  const NearbyBusinessSheet({
    super.key,
    required this.business,
    this.categoryName,
    this.onCenterOnMap,
  });

  final Business business;
  final String? categoryName;
  final VoidCallback? onCenterOnMap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = businessStatusColor(business.status, colorScheme);
    final isLive = businessIsLiveOnMap(business);

    return DraggableScrollableSheet(
      initialChildSize: 0.52,
      minChildSize: 0.38,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Material(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _BannerSection(business: business, isDark: isDark),
                  Positioned(
                    left: 20,
                    bottom: -28,
                    child: _LogoAvatar(business: business, size: 72),
                  ),
                  if (isLive)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: _LiveChip(statusColor: statusColor, label: businessStatusLabel(business.status)),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            business.businessName,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                          ),
                        ),
                        if (business.verificationStatus == BusinessVerificationStatus.verified)
                          const _VerifiedBadge(),
                      ],
                    ),
                    if (categoryName != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        categoryName!,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoChip(
                          icon: Icons.star_rounded,
                          label: business.reviewCount > 0
                              ? '${business.averageRating.toStringAsFixed(1)} (${business.reviewCount})'
                              : 'No reviews yet',
                          iconColor: Colors.amber.shade700,
                        ),
                        if (business.distanceMeters != null)
                          _InfoChip(
                            icon: Icons.near_me_rounded,
                            label: formatDistanceMeters(business.distanceMeters),
                            iconColor: colorScheme.primary,
                          ),
                        _InfoChip(
                          icon: Icons.circle,
                          label: businessStatusLabel(business.status),
                          iconColor: statusColor,
                          iconSize: 10,
                        ),
                      ],
                    ),
                    if (business.description != null && business.description!.trim().isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        'About',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        business.description!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                      ),
                    ],
                    if (business.lastSeenAt != null) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.schedule_rounded, size: 16, color: colorScheme.onSurfaceVariant),
                          const SizedBox(width: 6),
                          Text(
                            'Last seen ${_relativeTime(business.lastSeenAt!)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),
                    if (onCenterOnMap != null)
                      FilledButton.icon(
                        onPressed: onCenterOnMap,
                        icon: const Icon(Icons.my_location_rounded),
                        label: const Text('Show on map'),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _relativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class NearbyBusinessCarouselCard extends StatelessWidget {
  const NearbyBusinessCarouselCard({
    super.key,
    required this.business,
    required this.selected,
    required this.onTap,
    this.categoryName,
  });

  final Business business;
  final bool selected;
  final VoidCallback onTap;
  final String? categoryName;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = businessStatusColor(business.status, colorScheme);

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Material(
        elevation: selected ? 4 : 1,
        shadowColor: colorScheme.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        color: colorScheme.surface,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 260,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? colorScheme.primary : colorScheme.outlineVariant,
                width: selected ? 2 : 1,
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _LogoAvatar(business: business, size: 52),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        business.businessName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      if (categoryName != null)
                        Text(
                          categoryName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                        ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.star_rounded, size: 14, color: Colors.amber.shade700),
                          const SizedBox(width: 2),
                          Text(
                            business.reviewCount > 0
                                ? business.averageRating.toStringAsFixed(1)
                                : '—',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              formatDistanceMeters(business.distanceMeters),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BannerSection extends StatelessWidget {
  const _BannerSection({required this.business, required this.isDark});

  final Business business;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    if (business.bannerUrl != null) {
      return Image.network(
        business.bannerUrl!,
        height: 140,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _GradientBanner(isDark: isDark),
      );
    }
    return _GradientBanner(isDark: isDark);
  }
}

class _GradientBanner extends StatelessWidget {
  const _GradientBanner({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF4C1D95), const Color(0xFF312E81)]
              : [const Color(0xFF7C3AED), const Color(0xFF4338CA)],
        ),
      ),
      child: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Icon(Icons.storefront_rounded, size: 48, color: Colors.white.withValues(alpha: 0.25)),
        ),
      ),
    );
  }
}

class _LogoAvatar extends StatelessWidget {
  const _LogoAvatar({required this.business, required this.size});

  final Business business;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.surface, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: business.logoUrl != null
            ? Image.network(business.logoUrl!, fit: BoxFit.cover)
            : ColoredBox(
                color: colorScheme.primaryContainer,
                child: Icon(Icons.storefront_outlined, color: colorScheme.primary, size: size * 0.45),
              ),
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8, top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, size: 14, color: Colors.blue),
          SizedBox(width: 4),
          Text(
            'Verified',
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w700, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _LiveChip extends StatelessWidget {
  const _LiveChip({required this.statusColor, required this.label});

  final Color statusColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: statusColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: statusColor, fontWeight: FontWeight.w800, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.iconColor,
    this.iconSize = 16,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: iconColor),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}
