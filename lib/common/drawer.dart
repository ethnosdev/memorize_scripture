import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/theme_manager.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              children: [
                const Text('Memorize Scripture'),
                // const Spacer(),
                // Align(
                //   alignment: Alignment.bottomRight,
                //   child: ValueListenableBuilder<bool>(
                //     valueListenable: manager.isDarkListener,
                //     builder: (context, isDarkMode, child) {
                //       return IconButton(
                //         onPressed: () {
                //           manager.toggleTheme();
                //         },
                //         icon: (isDarkMode)
                //             ? const Icon(Icons.light_mode)
                //             : const Icon(Icons.dark_mode),
                //       );
                //     },
                //   ),
                // ),
              ],
            ),
          ),
          ListTile(
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              context.goNamed('settings');
            },
          ),
          ListTile(
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              context.goNamed('about');
            },
          ),
        ],
      ),
    );
  }
}
