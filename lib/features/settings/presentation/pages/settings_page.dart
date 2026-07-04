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
          'Preferences',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.person_outline, color: colorScheme.primary),
                title: const Text('Profile'),
                subtitle: const Text('Name, phone, and account details'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/profile'),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: Icon(Icons.palette_outlined, color: colorScheme.primary),
                title: const Text('Appearance'),
                subtitle: const Text('Theme and display'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/settings/theme'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Account',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.storefront_outlined, color: colorScheme.primary),
                title: const Text('Vendor setup'),
                subtitle: const Text('List products and manage stores — coming soon'),
                enabled: false,
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: Icon(Icons.photo_camera_outlined, color: colorScheme.primary),
                title: const Text('Profile photo'),
                subtitle: const Text('Upload your avatar from the profile page — coming soon'),
                enabled: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
