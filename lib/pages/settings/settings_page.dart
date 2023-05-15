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
      body: AnimatedBuilder(
        animation: manager,
        builder: (context, widget) {
          return SettingsList(
            sections: [
              SettingsSection(
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
                tiles: [
                  SettingsTile(
                    title: const Text('Max new verses per day'),
                    value: Text('${manager.dailyLimit}'),
                    onPressed: (BuildContext context) {
                      _showDailyLimitDialog();
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
