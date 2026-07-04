import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bitetrack/core/theme/app_colors.dart';
import 'package:bitetrack/core/widgets/profile_avatar.dart';
import 'package:bitetrack/features/auth/domain/entities/user.dart';
import 'package:bitetrack/features/auth/presentation/bloc/auth_bloc.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;
        final location = GoRouterState.of(context).matchedLocation;
        final canPop = context.canPop();

        return Scaffold(
          appBar: AppBar(
            leading: canPop
                ? const BackButton()
                : IconButton(
                    icon: const Icon(Icons.menu_rounded),
                    tooltip: 'Menu',
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
            title: _ShellTitle(location: location),
          ),
          drawer: user == null ? null : _AppDrawer(user: user),
          body: child,
        );
      },
    );
  }
}

class _ShellTitle extends StatelessWidget {
  const _ShellTitle({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    if (location == '/home') {
      return Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/logo.png',
              width: 28,
              height: 28,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),
          const SizedBox(width: 10),
          const Text('Discover'),
        ],
      );
    }

    if (location == '/profile') {
      return const Text('Profile');
    }

    if (location == '/settings/theme') {
      return const Text('Appearance');
    }

    if (location == '/settings') {
      return const Text('Settings');
    }

    return const Text('BiteTrack');
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final location = GoRouterState.of(context).matchedLocation;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () => _navigate(context, '/profile'),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: isDark ? AppDarkColors.brandGradient : AppColors.brandGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileAvatar(
                      displayName: user.displayName,
                      email: user.email,
                      size: 64,
                      showEditBadge: true,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.displayName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    if (user.firstName != null || user.lastName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _profileSubtitle(user),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.88),
                            ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.78),
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'View profile',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Menu',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
            const SizedBox(height: 4),
            _DrawerTile(
              icon: Icons.person_outline,
              label: 'Profile',
              selected: location == '/profile',
              onTap: () => _navigate(context, '/profile'),
            ),
            _DrawerTile(
              icon: Icons.explore_outlined,
              label: 'Discover',
              selected: location == '/home',
              onTap: () => _navigate(context, '/home'),
            ),
            _DrawerTile(
              icon: Icons.settings_outlined,
              label: 'Settings',
              selected: location.startsWith('/settings'),
              onTap: () => _navigate(context, '/settings'),
            ),
            const Spacer(),
            const Divider(height: 1),
            _DrawerTile(
              icon: Icons.logout_rounded,
              label: 'Sign out',
              destructive: true,
              onTap: () {
                Navigator.pop(context);
                context.read<AuthBloc>().add(const AuthLogoutRequested());
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _profileSubtitle(User user) {
    final parts = <String>[];
    if (user.firstName != null && user.firstName!.isNotEmpty) {
      parts.add(user.firstName!);
    }
    if (user.lastName != null && user.lastName!.isNotEmpty) {
      parts.add(user.lastName!);
    }
    return parts.join(' ');
  }

  void _navigate(BuildContext context, String path) {
    Navigator.pop(context);
    if (GoRouterState.of(context).matchedLocation != path) {
      context.go(path);
    }
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = destructive
        ? colorScheme.error
        : selected
            ? colorScheme.primary
            : colorScheme.onSurface;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      selected: selected,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
    );
  }
}
