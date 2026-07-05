import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text(
          'App',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: Icon(Icons.palette_outlined, color: colorScheme.primary),
            title: const Text('Appearance'),
            subtitle: const Text('Light, dark, or system theme'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/settings/theme'),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Business',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: Icon(Icons.storefront_outlined, color: colorScheme.primary),
            title: const Text('My businesses'),
            subtitle: const Text('Register shops, brands, and products'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/businesses'),
          ),
        ),
      ],
    );
  }
}
