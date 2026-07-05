import 'package:flutter/material.dart';

/// Shimmer-style skeleton blocks for Discover home panels.
class DiscoverSkeleton extends StatefulWidget {
  const DiscoverSkeleton({
    super.key,
    required this.child,
    this.enabled = true,
  });

  final Widget child;
  final bool enabled;

  @override
  State<DiscoverSkeleton> createState() => _DiscoverSkeletonState();
}

class _DiscoverSkeletonState extends State<DiscoverSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0xFFE8E8E8),
                Color(0xFFF5F5F5),
                Color(0xFFE8E8E8),
              ],
              stops: [
                (_controller.value - 0.3).clamp(0.0, 1.0),
                _controller.value.clamp(0.0, 1.0),
                (_controller.value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class DiscoverMapPreviewSkeleton extends StatelessWidget {
  const DiscoverMapPreviewSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;

    return DiscoverSkeleton(
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 180,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: base),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: _SkeletonBox(height: 44, borderRadius: 14, color: base),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DiscoverCategoryChipsSkeleton extends StatelessWidget {
  const DiscoverCategoryChipsSkeleton({super.key});

  static const _chipWidths = [72.0, 80.0, 88.0, 96.0, 104.0];

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;

    return DiscoverSkeleton(
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _chipWidths.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            return _SkeletonBox(
              width: _chipWidths[index],
              height: 36,
              borderRadius: 999,
              color: base,
            );
          },
        ),
      ),
    );
  }
}

class DiscoverBusinessListSkeleton extends StatelessWidget {
  const DiscoverBusinessListSkeleton({super.key, this.count = 3});

  final int count;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;

    return DiscoverSkeleton(
      child: Column(
        children: List.generate(
          count,
          (i) => Padding(
            padding: EdgeInsets.only(bottom: i == count - 1 ? 0 : 10),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    _SkeletonBox(width: 56, height: 56, borderRadius: 12, color: base),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SkeletonBox(width: double.infinity, height: 14, borderRadius: 6, color: base),
                          const SizedBox(height: 8),
                          _SkeletonBox(width: 100, height: 12, borderRadius: 6, color: base),
                          const SizedBox(height: 8),
                          _SkeletonBox(width: 140, height: 12, borderRadius: 6, color: base),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.height,
    required this.borderRadius,
    required this.color,
    this.width,
  });

  final double? width;
  final double height;
  final double borderRadius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
