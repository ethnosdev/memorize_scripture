import 'package:flutter/material.dart';
import 'package:memorize_scripture/common/dialog/set_number_dialog.dart';
import 'package:memorize_scripture/pages/settings/settings_page_manager.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final manager = SettingsPageManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListenableBuilder(
        listenable: manager,
        builder: (context, widget) {
          return ListView(
            children: [
              _buildSectionHeader(context, 'Appearance'),
              ListTile(
                title: const Text('Theme'),
                subtitle: Text(manager.themeMode == ThemeMode.light
                    ? 'Light'
                    : manager.themeMode == ThemeMode.dark
                        ? 'Dark'
                        : 'System Default'),
                trailing: Icon(
                  manager.themeMode == ThemeMode.light
                      ? Icons.light_mode
                      : manager.themeMode == ThemeMode.dark
                          ? Icons.dark_mode
                          : Icons.smartphone,
                ),
                onTap: () {
                  _showThemeDialog(context);
                },
              ),
              const Divider(),
              _buildSectionHeader(context, 'Practice'),
              ListTile(
                title: const Text('Max new verses per day'),
                trailing: Text(
                  manager.dailyLimit,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                onTap: () {
                  showSetNumberDialog(
                    context: context,
                    title: 'Daily limit',
                    oldValue: manager.dailyLimit,
                    onValidate: manager.validateDailyLimit,
                    onConfirm: manager.updateDailyLimit,
                  );
                },
              ),
              const Divider(),
              _buildSectionHeader(context, 'Experimental'),
              SwitchListTile(
                title: const Text('Sort in biblical order'),
                value: manager.isBiblicalOrder,
                activeThumbColor: Theme.of(context).colorScheme.primary,
                onChanged: (value) {
                  manager.setIsBiblicalOrder(value);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SegmentedButton<ThemeMode>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment<ThemeMode>(
              value: ThemeMode.light,
              icon: Icon(Icons.light_mode),
            ),
            ButtonSegment<ThemeMode>(
              value: ThemeMode.system,
              icon: Icon(Icons.smartphone),
            ),
            ButtonSegment<ThemeMode>(
              value: ThemeMode.dark,
              icon: Icon(Icons.dark_mode),
            ),
          ],
          selected: {manager.themeMode},
          onSelectionChanged: (Set<ThemeMode> selection) {
            manager.setThemeMode(selection.first);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
