import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:memorize_scripture/app_manager.dart';
import 'package:memorize_scripture/common/color.dart';
import 'package:memorize_scripture/go_router.dart';
import 'package:memorize_scripture/service_locator.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = getIt<AppManager>().isDarkTheme;
    return SizedBox(
      width: 200,
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: SvgPicture.asset(
                colorFilter: (isDark)
                    ? const ColorFilter.mode(
                        customYellow,
                        BlendMode.srcIn,
                      )
                    : null,
                'assets/logo.svg',
                width: 100,
                height: 100,
              ),
            ),
            ListTile(
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                context.goNamed(RouteName.settings);
              },
            ),
            ListTile(
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                context.goNamed(RouteName.about);
              },
            ),
          ],
        ),
      ),
    );
  }
}
