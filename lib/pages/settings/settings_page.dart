import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListenableBuilder(
        listenable: manager,
        builder: (context, widget) {
          return SettingsList(
            sections: [
              SettingsSection(
                title: const Text('Appearance'),
                tiles: [
                  SettingsTile.switchTile(
                    activeSwitchColor: Theme.of(context).colorScheme.primary,
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
                    value: Text('${manager.dailyLimit}'),
                    onPressed: (BuildContext context) {
                      _showDailyLimitDialog();
                    },
                  ),
                  SettingsTile.switchTile(
                    activeSwitchColor: Theme.of(context).colorScheme.primary,
                    title: const Text('Two-button mode'),
                    initialValue: manager.isTwoButtonMode,
                    onToggle: manager.setTwoButtonMode,
                  ),
                ],
              ),
              SettingsSection(
                title: const Text('Notifications'),
                tiles: [
                  SettingsTile.switchTile(
                    activeSwitchColor: Theme.of(context).colorScheme.primary,
                    title: const Text('Daily reminder'),
                    initialValue: manager.isNotificationsOn,
                    onToggle: manager.setNotifications,
                  ),
                  SettingsTile(
                    enabled: manager.isNotificationsOn,
                    title: const Text('Time'),
                    value: Text(manager.notificationTimeDisplay),
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
            ],
          );
        },
      ),
    );
  }

  Future<String?> _showDailyLimitDialog() async {
    int count = manager.dailyLimit;
    final controller = TextEditingController(text: count.toString());
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        manager.updateDailyLimit(count);
        Navigator.of(context).pop(controller.text);
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Daily limit"),
      content: TextField(
        autofocus: true,
        keyboardType: TextInputType.number,
        controller: controller,
        onChanged: (value) {
          count = manager.validateDailyLimit(value);
        },
        onTap: () {
          controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: controller.value.text.length,
          );
        },
      ),
      actions: [okButton],
    );

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
