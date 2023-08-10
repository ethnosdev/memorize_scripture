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
                    // description: (manager.isTwoButtonMode)
                    //     ? const Text('Hard, Good')
                    //     : const Text('Hard, OK, Good, Easy'),
                    initialValue: manager.isTwoButtonMode,
                    onToggle: manager.setTwoButtonMode,
                  ),
                ],
              ),
              // SettingsSection(
              //   tiles: [
              //     SettingsTile.switchTile(
              //       activeSwitchColor: Theme.of(context).colorScheme.primary,
              //       title: const Text('Two-button response'),
              //       description: (manager.isTwoButtonMode)
              //           ? const Text('Hard, Good')
              //           : const Text('Hard, OK, Good, Easy'),
              //       initialValue: manager.isTwoButtonMode,
              //       onToggle: manager.setTwoButtonMode,
              //     ),
              //   ],
              // ),
              SettingsSection(
                title: const Text('Notifications'),
                tiles: [
                  SettingsTile.switchTile(
                    activeSwitchColor: Theme.of(context).colorScheme.primary,
                    title: const Text('Daily reminder'),
                    // description: const Text('A daily reminder to practice your '
                    //     'verses if you haven\'t already.'),
                    initialValue: false,
                    onToggle: (value) {},
                  ),
                  SettingsTile(
                    enabled: false,
                    title: const Text('Time'),
                    value: const Text('8pm'),
                    onPressed: null,
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
