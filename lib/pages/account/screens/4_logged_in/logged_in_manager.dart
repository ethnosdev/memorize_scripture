import 'package:flutter/material.dart';
import 'package:memorize_scripture/pages/account/shared/account_screen_type.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/auth/auth_service.dart';

class LoggedInManager {
  LoggedInManager({required this.screenNotifier});
  final ValueNotifier<AccountScreenType> screenNotifier;

  final emailNotifier = ValueNotifier('');

  Future<void> init() async {
    final user = await getIt<AuthService>().getUser();
    emailNotifier.value = user.email;
  }

  Future<void> signOut() async {
    await getIt<AuthService>().signOut();
    screenNotifier.value = AccountScreenType.signIn;
    // TODO: delete token from secure storage
  }

  Future<void> deleteAccount() async {
    await getIt<AuthService>().deleteAccount();
    screenNotifier.value = AccountScreenType.signUp;
    // TODO: delete token and email from secure storage
    // TODO: mark all verses as unsynced
  }
}
