/// Returns an error message if an invalid email.
String? validateEmail(String email) {
  final emailRegex =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  if (email.isEmpty) {
    return 'Email cannot be empty';
  } else if (!emailRegex.hasMatch(email)) {
    return 'Invalid email address';
  }
  return null;
}

/// Returns an error message if an invalid passphrase.
String? validatePassphrase(String passphrase) {
  final words = passphrase.split(' ');
  var count = 0;
  for (final word in words) {
    if (word.isNotEmpty) {
      count++;
    }
  }

  if (passphrase.isEmpty) {
    return 'Passphrase cannot be empty';
  } else if (count < 4) {
    return 'Must contain at least four words separated by spaces';
  }

  return null;
}
