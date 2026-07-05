import 'package:flutter/material.dart';
import 'package:bitetrack/features/business/domain/entities/business.dart';
import 'package:bitetrack/features/discover/presentation/widgets/nearby_business_sheet.dart';

class NearbyBusinessCompactCard extends StatelessWidget {
  const NearbyBusinessCompactCard({
    super.key,
    required this.business,
    required this.categoryName,
    required this.onTap,
  });

  final Business business;
  final String? categoryName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = businessStatusColor(business.status, colorScheme);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _LogoThumb(business: business),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            business.businessName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        if (businessIsLiveOnMap(business))
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'LIVE',
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (categoryName != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        categoryName!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, size: 14, color: Colors.amber.shade700),
                        const SizedBox(width: 2),
                        Text(
                          business.reviewCount > 0
                              ? business.averageRating.toStringAsFixed(1)
                              : 'New',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(width: 10),
                        Icon(Icons.near_me_rounded, size: 14, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            formatDistanceMeters(business.distanceMeters),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoThumb extends StatelessWidget {
  const _LogoThumb({required this.business});

  final Business business;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 56,
        height: 56,
        color: colorScheme.primaryContainer,
        child: business.logoUrl != null
            ? Image.network(business.logoUrl!, fit: BoxFit.cover)
            : Icon(Icons.storefront_outlined, color: colorScheme.primary),
      ),
    );
  }
}
