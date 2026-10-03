import 'package:flutter/material.dart';
import 'package:memorize_scripture/common/dialog/set_number_dialog.dart';
import 'package:memorize_scripture/pages/settings/settings_page_manager.dart';
import 'package:memorize_scripture/services/user_settings.dart';

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
              ListTile(
                title: const Text('Font size'),
                trailing: Text(
                  manager.fontSize.round().toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                onTap: () {
                  _showFontSizeDialog(context);
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
              _buildSectionHeader(context, 'Notifications'),
              SwitchListTile(
                title: const Text('Daily reminder'),
                value: manager.isNotificationsOn,
                activeThumbColor: Theme.of(context).colorScheme.primary,
                onChanged: (value) {
                  manager.setNotifications(value);
                },
              ),
              ListTile(
                enabled: manager.isNotificationsOn,
                title: Text(
                  'Time',
                  style: (!manager.isNotificationsOn)
                      ? TextStyle(color: Theme.of(context).disabledColor)
                      : null,
                ),
                trailing: Text(
                  manager.notificationTimeDisplay,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: (!manager.isNotificationsOn)
                            ? Theme.of(context).disabledColor
                            : null,
                      ),
                ),
                onTap: manager.isNotificationsOn
                    ? () async {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(
                            hour: manager.notificationTimeHour,
                            minute: manager.notificationTimeMinute,
                          ),
                        );
                        if (pickedTime == null) return;
                        manager.setNotificationTime(
                          hour: pickedTime.hour,
                          minute: pickedTime.minute,
                        );
                      }
                    : null,
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

  void _showFontSizeDialog(BuildContext context) {
    double currentSize = manager.fontSize;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 60,
                    child: Center(
                      child: Text(
                        'Text',
                        style: TextStyle(fontSize: currentSize),
                      ),
                    ),
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      showValueIndicator: ShowValueIndicator.onDrag,
                    ),
                    child: Slider(
                      value: currentSize,
                      min: UserSettings.minFontSize,
                      max: UserSettings.maxFontSize,
                      divisions: (UserSettings.maxFontSize - UserSettings.minFontSize).round(),
                      label: currentSize.round().toString(),
                      onChanged: (value) {
                        setDialogState(() {
                          currentSize = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    manager.setFontSize(currentSize);
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
