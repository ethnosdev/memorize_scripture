import 'package:flutter/material.dart';

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
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text('Memorize Scripture'),
          ),
          ListTile(
            title: const Text('Settings'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('About'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
