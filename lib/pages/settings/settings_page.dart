import 'package:flutter/material.dart';
import 'package:memorize_scripture/common/dialog/set_number_dialog.dart';
import 'package:memorize_scripture/pages/settings/settings_page_manager.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final manager = SettingsPageManager();

  @override
  void initState() {
    super.initState();
    manager.init();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final disabledColor = Theme.of(context).disabledColor;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListenableBuilder(
        listenable: manager,
        builder: (context, widget) {
          return SettingsList(
            lightTheme: SettingsThemeData(
              settingsListBackground: colorScheme.surface,
              settingsSectionBackground: colorScheme.surfaceContainerHighest,
              dividerColor: colorScheme.surface,
              titleTextColor: colorScheme.secondary,
            ),
            darkTheme: SettingsThemeData(
              settingsListBackground: colorScheme.surface,
              settingsSectionBackground: colorScheme.surfaceContainerHighest,
              dividerColor: colorScheme.surface,
              titleTextColor: colorScheme.secondary,
            ),
            sections: [
              SettingsSection(
                title: const Text('Appearance'),
                tiles: [
                  SettingsTile.switchTile(
                    activeSwitchColor: colorScheme.primary,
                    title: const Text('Dark mode'),
                    initialValue: manager.isDarkMode,
                    onToggle: manager.setDarkMode,
                  ),
                ],
              ),
              SettingsSection(
                title: const Text('Practice'),
                tiles: [
                  SettingsTile(
                    title: const Text('Max new verses per day'),
                    value: Text(manager.dailyLimit),
                    onPressed: (BuildContext context) {
                      showSetNumberDialog(
                        context: context,
                        title: 'Daily limit',
                        oldValue: manager.dailyLimit,
                        onValidate: manager.validateDailyLimit,
                        onConfirm: manager.updateDailyLimit,
                      );
                    },
                  ),
                ],
              ),
              SettingsSection(
                title: const Text('Notifications'),
                tiles: [
                  SettingsTile.switchTile(
                    activeSwitchColor: colorScheme.primary,
                    title: const Text('Daily reminder'),
                    initialValue: manager.isNotificationsOn,
                    onToggle: manager.setNotifications,
                  ),
                  SettingsTile(
                    enabled: manager.isNotificationsOn,
                    title: Text(
                      'Time',
                      style: (!manager.isNotificationsOn) ? TextStyle(color: disabledColor) : null,
                    ),
                    value: Text(
                      manager.notificationTimeDisplay,
                      style: (!manager.isNotificationsOn) ? TextStyle(color: disabledColor) : null,
                    ),
                    onPressed: (context) async {
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
                    },
                  ),
                ],
              ),
              SettingsSection(
                title: const Text('Experimental'),
                tiles: [
                  SettingsTile.switchTile(
                    activeSwitchColor: colorScheme.primary,
                    title: const Text('Sort in biblical order'),
                    initialValue: manager.isBiblicalOrder,
                    onToggle: manager.setIsBiblicalOrder,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
