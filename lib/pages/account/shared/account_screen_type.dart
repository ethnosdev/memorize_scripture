import 'package:memorize_scripture/services/backend/auth/user.dart';

sealed class AccountScreenType {}

class Initial extends AccountScreenType {}

class Loading extends AccountScreenType {}

class SignUp extends AccountScreenType {}

class SignIn extends AccountScreenType {
  SignIn({required this.email});
  final String email;
}

class NewPassword extends AccountScreenType {
  NewPassword({required this.email});
  final String email;
}

class LoggedIn extends AccountScreenType {
  LoggedIn({required this.user});
  final User user;
}
