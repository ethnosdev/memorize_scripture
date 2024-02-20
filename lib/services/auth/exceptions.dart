class EmailException implements Exception {
  EmailException(this.message);
  final String message;
}

class PasswordException implements Exception {
  PasswordException(this.message);
  final String message;
}

class FailedToAuthenticateException implements Exception {
  FailedToAuthenticateException(this.message);
  final String message;
}

class ConnectionRefusedException implements Exception {
  final message = 'There was a problem connecting to the server';
}

class UserNotVerifiedException implements Exception {
  UserNotVerifiedException(this.message);
  final String message;
}
