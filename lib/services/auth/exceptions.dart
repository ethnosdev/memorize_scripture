class EmailException implements Exception {
  EmailException(this.message);
  final String message;
}

class PasswordException implements Exception {
  PasswordException(this.message);
  final String message;
}

class UserNotVerifiedException implements Exception {
  UserNotVerifiedException(this.message);
  final String message;
}
