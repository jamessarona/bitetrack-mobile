import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bitetrack/core/di/injection.dart';
import 'package:bitetrack/core/error/failures.dart';
import 'package:bitetrack/core/theme/app_colors.dart';
import 'package:bitetrack/core/theme/theme_cubit.dart';
import 'package:bitetrack/core/theme/theme_preference.dart';
import 'package:bitetrack/features/auth/domain/entities/user.dart';
import 'package:bitetrack/features/auth/domain/usecases/auth_usecases.dart';
import 'package:bitetrack/features/auth/presentation/bloc/auth_bloc.dart';

class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Center(child: Text('Sign in to save theme preferences'));
        }

        return _ThemePreferenceBody(user: state.user);
      },
    );
  }
}

class _ThemePreferenceBody extends StatefulWidget {
  const _ThemePreferenceBody({required this.user});

  final User user;

  @override
  State<_ThemePreferenceBody> createState() => _ThemePreferenceBodyState();
}

class _ThemePreferenceBodyState extends State<_ThemePreferenceBody> {
  bool _isSaving = false;

  Future<void> _select(AppThemePreference preference) async {
    if (_isSaving || preference == widget.user.themePreference) return;

    setState(() => _isSaving = true);
    context.read<ThemeCubit>().syncFromPreference(preference);

    try {
      final updatedUser = await getIt<UpdateThemePreferenceUseCase>()(preference);
      if (!mounted) return;
      context.read<AuthBloc>().add(AuthUserUpdated(updatedUser));
    } on Failure catch (e) {
      if (!mounted) return;
      context.read<ThemeCubit>().syncFromPreference(widget.user.themePreference);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      context.read<ThemeCubit>().syncFromPreference(widget.user.themePreference);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save theme preference')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text(
          'Choose a theme for BiteTrack. Your preference syncs across devices when signed in.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
        ),
        const SizedBox(height: 20),
        ...AppThemePreference.values.map(
          (preference) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ThemeOptionCard(
              preference: preference,
              selected: widget.user.themePreference == preference,
              loading: _isSaving,
              onTap: () => _select(preference),
            ),
          ),
        ),
      ],
    );
  }
}

class _ThemeOptionCard extends StatelessWidget {
  const _ThemeOptionCard({
    required this.preference,
    required this.selected,
    required this.loading,
    required this.onTap,
  });

  final AppThemePreference preference;
  final bool selected;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: selected ? colorScheme.primaryContainer.withValues(alpha: 0.45) : colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? colorScheme.primary : colorScheme.outline,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              _ThemePreview(preference: preference),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      preference.label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      preference.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                    ),
                  ],
                ),
              ),
              if (selected && loading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (selected)
                Icon(Icons.check_circle_rounded, color: colorScheme.primary)
              else
                Icon(Icons.circle_outlined, color: colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemePreview extends StatelessWidget {
  const _ThemePreview({required this.preference});

  final AppThemePreference preference;

  @override
  Widget build(BuildContext context) {
    final (background, accent, surface) = switch (preference) {
      AppThemePreference.light => (AppColors.background, AppColors.primary, AppColors.surface),
      AppThemePreference.dark => (AppDarkColors.background, AppDarkColors.primary, AppDarkColors.surface),
      AppThemePreference.system => (const Color(0xFFE5E7EB), AppColors.primary, Colors.white),
    };

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18,
            height: 4,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            height: 14,
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
