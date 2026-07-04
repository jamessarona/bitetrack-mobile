import 'package:flutter/material.dart';
import 'package:bitetrack/core/theme/app_colors.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 96,
    this.showLabel = true,
    this.compact = false,
    this.plain = false,
  });

  final double size;
  final bool showLabel;
  final bool compact;

  /// When true, renders the icon asset only — no extra clip, shadow, or frame.
  final bool plain;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LogoImage(size: size, plain: plain),
        if (showLabel) ...[
          SizedBox(height: compact ? 12 : 16),
          Text(
            'BiteTrack',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: plain ? Colors.white : AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
          ),
          if (!compact) ...[
            const SizedBox(height: 4),
            Text(
              'Track your next bite',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: plain
                        ? Colors.white.withValues(alpha: 0.88)
                        : AppColors.textSecondary,
                  ),
            ),
          ],
        ],
      ],
    );
  }
}

class _LogoImage extends StatelessWidget {
  const _LogoImage({required this.size, required this.plain});

  final double size;
  final bool plain;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      'assets/images/logo.png',
      width: size,
      height: size,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
    );

    if (plain) {
      return image;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: size * 0.2,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.24),
        child: image,
      ),
    );
  }
}
