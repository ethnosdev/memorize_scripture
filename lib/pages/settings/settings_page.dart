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
                    title: const Text('Dark mode'),
                    initialValue: manager.isDarkMode,
                    onToggle: manager.setDarkMode,
                  ),
                ],
              ),
              SettingsSection(
                tiles: [
                  SettingsTile(
                    title: Text('New verse frequency'),
                    value: Text('5 per day'),
                    onPressed: (BuildContext context) {
                      showCustomDialog(context);
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

  void showCustomDialog(BuildContext context) {
    int count = 1;
    String period = 'day';

    final TextEditingController _controller =
        TextEditingController(text: '$count');
    final FocusNode _focusNode = FocusNode();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Set Limit'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 50,
                child: TextFormField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  focusNode: _focusNode,
                  controller: _controller,
                  onChanged: (value) {
                    count = int.tryParse(value) ?? 1;
                  },
                  onTap: () {
                    _controller.selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: _controller.value.text.length,
                    );
                  },
                ),
              ),
              SizedBox(width: 8),
              Text('per'),
              SizedBox(width: 8),
              SizedBox(
                width: 100,
                child: DropdownButtonFormField<String>(
                  alignment: Alignment.centerLeft,
                  value: period,
                  onChanged: (value) {
                    period = value ?? 'day';
                  },
                  items: const [
                    DropdownMenuItem<String>(
                      value: 'day',
                      child: Center(child: Text('day')),
                    ),
                    DropdownMenuItem<String>(
                      value: 'week',
                      child: Center(child: Text('week')),
                    ),
                    DropdownMenuItem<String>(
                      value: 'month',
                      child: Center(child: Text('month')),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Do something with count and period
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
