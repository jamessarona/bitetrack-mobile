import 'package:flutter/material.dart';
import 'package:bitetrack/features/business/domain/entities/business.dart';
import 'package:bitetrack/features/discover/presentation/widgets/nearby_business_sheet.dart';

/// Fixed-size business pin — sized to fit flutter_map [Marker] constraints.
class BusinessMapMarker extends StatelessWidget {
  const BusinessMapMarker({
    super.key,
    required this.business,
    required this.selected,
    required this.clusterSize,
    required this.onTap,
  });

  final Business business;
  final bool selected;
  final int clusterSize;
  final VoidCallback onTap;

  static const double markerWidth = 52;
  static const double markerHeight = 58;

  static const double _bodySize = 42;
  static const double _tailHeight = 7;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = businessStatusColor(business.status, colorScheme);
    final isLive = businessIsLiveOnMap(business);
    final borderWidth = selected ? 3.0 : 2.0;
    final bodySize = selected ? _bodySize + 2 : _bodySize;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: markerWidth,
        height: markerHeight,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              top: 0,
              left: (markerWidth - bodySize) / 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: bodySize,
                        height: bodySize,
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(
                            color: selected ? colorScheme.primary : statusColor,
                            width: borderWidth,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: statusColor.withValues(alpha: 0.35),
                              blurRadius: selected ? 10 : 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: business.logoUrl != null
                              ? Image.network(business.logoUrl!, fit: BoxFit.cover)
                              : ColoredBox(
                                  color: colorScheme.primaryContainer,
                                  child: Icon(
                                    Icons.storefront_rounded,
                                    color: colorScheme.primary,
                                    size: bodySize * 0.48,
                                  ),
                                ),
                        ),
                      ),
                      if (isLive)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: const Text(
                              'LIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 7,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                              ),
                            ),
                          ),
                        ),
                      if (clusterSize > 1)
                        Positioned(
                          top: -2,
                          left: -2,
                          child: Container(
                            width: 16,
                            height: 16,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: colorScheme.secondary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: Text(
                              '$clusterSize',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  CustomPaint(
                    size: const Size(12, _tailHeight),
                    painter: _PinTailPainter(color: selected ? colorScheme.primary : statusColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Blue navigation-style dot for the customer's current location.
class UserMapMarker extends StatelessWidget {
  const UserMapMarker({super.key, this.clusterSize = 1});

  final int clusterSize;

  static const double markerWidth = 36;
  static const double markerHeight = 36;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: markerWidth,
      height: markerHeight,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.hardEdge,
        children: [
          Container(
            width: markerWidth,
            height: markerWidth,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withValues(alpha: 0.15),
            ),
          ),
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1A73E8),
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: const Icon(Icons.navigation_rounded, color: Colors.white, size: 14),
          ),
          if (clusterSize > 1)
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFF1557B0),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Text(
                  '$clusterSize',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 7,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PinTailPainter extends CustomPainter {
  _PinTailPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _PinTailPainter oldDelegate) => oldDelegate.color != color;
}

/// @deprecated Use [BusinessMapMarker].
typedef NearbyBusinessMapMarker = BusinessMapMarker;
