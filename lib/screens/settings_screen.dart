import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: RadioGroup<ThemeMode>(
        groupValue: themeMode,
        onChanged: (ThemeMode? value) {
          if (value != null) {
            ref.read(themeProvider.notifier).setTheme(value);
          }
        },
        child: ListView(
          children: [
            if (user != null) ...[
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Account',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    user.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(user.displayName ?? 'User'),
                subtitle: Text(user.email ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.logout, color: Colors.red),
                  onPressed: () async {
                    final logout = await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Logout'),
                            content: const Text(
                              'Are you sure you want to logout?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  'Logout',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                    );

                    if (logout == true) {
                      await ref.read(authServiceProvider).logout();
                      if (context.mounted) {
                        Navigator.pop(context); // Close settings screen
                      }
                    }
                  },
                ),
              ),
              const Divider(),
            ],
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Theme',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildThemeOption(
              context,
              title: 'Light Theme',
              subtitle: 'Use light theme',
              themeMode: ThemeMode.light,
              currentThemeMode: themeMode,
              icon: Icons.light_mode,
            ),
            _buildThemeOption(
              context,
              title: 'Dark Theme',
              subtitle: 'Use dark theme',
              themeMode: ThemeMode.dark,
              currentThemeMode: themeMode,
              icon: Icons.dark_mode,
            ),
            _buildThemeOption(
              context,
              title: 'System Theme',
              subtitle: 'Follow system settings',
              themeMode: ThemeMode.system,
              currentThemeMode: themeMode,
              icon: Icons.brightness_auto,
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'About',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Version'),
              subtitle: const Text('1.0.0'),
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('App Name'),
              subtitle: const Text('Vehicle Service Tracker'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required ThemeMode themeMode,
    required ThemeMode currentThemeMode,
    required IconData icon,
  }) {
    final isSelected = themeMode == currentThemeMode;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: RadioListTile<ThemeMode>(
        value: themeMode,
        selected: isSelected,
        title: Row(
          children: [
            Icon(
              icon,
              color:
                  isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 16),
            Text(title),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(left: 40),
          child: Text(subtitle),
        ),
        activeColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
