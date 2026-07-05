import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:bitetrack/core/error/failures.dart';
import 'package:bitetrack/core/di/injection.dart';
import 'package:bitetrack/features/business/data/services/live_selling_location_service.dart';
import 'package:bitetrack/features/business/data/repositories/business_repository.dart';
import 'package:bitetrack/features/business/domain/entities/business.dart';

class SellingPanel extends StatefulWidget {
  const SellingPanel({
    super.key,
    required this.business,
    required this.repository,
    required this.onBusinessUpdated,
  });

  final Business business;
  final BusinessRepository repository;
  final ValueChanged<Business> onBusinessUpdated;

  @override
  State<SellingPanel> createState() => _SellingPanelState();
}

class _SellingPanelState extends State<SellingPanel> {
  final _locationService = getIt<LiveSellingLocationService>();
  bool _busy = false;

  @override
  void didUpdateWidget(covariant SellingPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.business.isLive && !widget.business.isLive) {
      _locationService.stop();
    } else if (!oldWidget.business.isLive && widget.business.isLive) {
      _locationService.start(widget.business.id);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.business.isLive) {
      _locationService.start(widget.business.id);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _ensureLocationPermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<Position?> _currentPosition() async {
    final allowed = await _ensureLocationPermission();
    if (!allowed) return null;
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  Future<void> _goLive() async {
    setState(() => _busy = true);
    try {
      final position = await _currentPosition();
      if (position == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission is required to go live')),
        );
        return;
      }

      final updated = await widget.repository.startSelling(
        businessId: widget.business.id,
        latitude: position.latitude,
        longitude: position.longitude,
      );
      widget.onBusinessUpdated(updated);
      _locationService.start(updated.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You are live — customers can find you on the map')),
      );
    } on Failure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _stopSelling() async {
    setState(() => _busy = true);
    try {
      final updated = await widget.repository.stopSelling(businessId: widget.business.id);
      widget.onBusinessUpdated(updated);
      _locationService.stop();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You are offline')),
      );
    } on Failure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final business = widget.business;

    if (business.isLive) {
      return Card(
        color: colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.radar_rounded, color: colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Live on the map',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onPrimaryContainer,
                          ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Your location updates automatically every 10 seconds while you are live.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer.withValues(alpha: 0.85),
                    ),
              ),
              const SizedBox(height: 14),
              FilledButton.tonal(
                onPressed: _busy ? null : _stopSelling,
                style: FilledButton.styleFrom(
                  foregroundColor: colorScheme.error,
                ),
                child: _busy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Stop selling'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Ready to sell?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              business.canGoLive
                  ? 'Go live to share your location so customers can find you on the map.'
                  : 'Your business needs to be verified before you can go live.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: _busy || !business.canGoLive ? null : _goLive,
              icon: const Icon(Icons.radar_rounded),
              label: _busy
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Go live'),
            ),
          ],
        ),
      ),
    );
  }
}
