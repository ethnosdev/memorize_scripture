import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:memorize_scripture/common/strings.dart';
import 'package:memorize_scripture/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Column(
                children: [
                  SvgPicture.asset(
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.primary,
                      BlendMode.srcIn,
                    ),
                    'assets/logo.svg',
                    width: 100,
                    height: 100,
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Memorize Scripture',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                ],
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
              title: const Text('Account'),
              onTap: () {
                Navigator.pop(context);
                context.goNamed(RouteName.account);
              },
            ),
            ListTile(
              title: const Text('Help'),
              onTap: () async {
                Navigator.pop(context);
                final url = Uri.parse(AppStrings.tutorialUrl);
                if (await canLaunchUrl(url)) {
                  launchUrl(url, mode: LaunchMode.externalApplication);
                }
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
