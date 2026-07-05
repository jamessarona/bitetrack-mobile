import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bitetrack/core/theme/app_colors.dart';
import 'package:bitetrack/core/widgets/profile_avatar.dart';
import 'package:bitetrack/features/auth/domain/entities/user.dart';
import 'package:bitetrack/features/auth/presentation/bloc/auth_bloc.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _showBackButton(String location) {
    return location == '/settings/theme' ||
        location == '/discover/map' ||
        location.startsWith('/businesses');
  }

  bool _isFullBleedRoute(String location) => location == '/discover/map';

  void _handleBack(BuildContext context, String location) {
    if (location == '/discover/map') {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/home');
      }
      return;
    }
    if (context.canPop()) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;
        final location = GoRouterState.of(context).matchedLocation;
        final fullBleed = _isFullBleedRoute(location);

        return Scaffold(
          key: _scaffoldKey,
          extendBodyBehindAppBar: fullBleed,
          appBar: fullBleed
              ? null
              : AppBar(
                  leading: _showBackButton(location)
                      ? BackButton(onPressed: () => _handleBack(context, location))
                      : IconButton(
                          icon: const Icon(Icons.menu_rounded),
                          tooltip: 'Menu',
                          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                        ),
                  title: _ShellTitle(location: location),
                ),
          drawer: user == null ? null : _AppDrawer(user: user),
          body: widget.child,
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

    if (location == '/discover/map') {
      return const Text('Map');
    }

    if (location.startsWith('/businesses')) {
      return const Text('My businesses');
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
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: isDark ? AppDarkColors.brandGradient : AppColors.brandGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  ProfileAvatar(
                    displayName: user.displayName,
                    email: user.email,
                    size: 56,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.82),
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
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

  void _navigate(BuildContext context, String path) {
    final router = GoRouter.of(context);
    final current = GoRouterState.of(context).matchedLocation;

    Navigator.pop(context);

    if (current != path) {
      router.go(path);
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
