Map<String, dynamic> parseOneAddress(String user) {
  final parts = user.split(RegExp(r'[<>]'));
  if (parts.length > 1 && parts[1].contains('@') && parts[2].isEmpty) {
    return {'name': parts[0].trim(), 'email': parts[1].trim()};
  } else if (parts.length == 1 && parts[0].contains('@')) {
    return {'name': null, 'email': parts[0].trim()};
  } else {
    throw ArgumentError(
        'Could not parse name and email from user option "$user" '
        '(format should be "Your Name <email@example.com>")');
  }
}

void requireArgument(bool truth, String argName, [String? message]) {
  metaRequireArgumentNotNullOrEmpty(argName);
  if (!truth) {
    if (message == null || message.isEmpty) {
      message = 'value was invalid';
    }
    throw ArgumentError(message);
  }
}

void requireArgumentNotNullOrEmpty(String? argument, String argName) {
  metaRequireArgumentNotNullOrEmpty(argName);
  if (argument == null) {
    throw ArgumentError.notNull(argument);
  } else if (argument.isEmpty) {
    throw ArgumentError.value(argument, argName, 'cannot be an empty string');
  }
}

void metaRequireArgumentNotNullOrEmpty(String argName) {
  if (argName.isEmpty) {
    throw const _InvalidOperationError(
      "That's just sad. Give me a good argName",
    );
  }
}

class _InvalidOperationError implements Exception {
  final String message;

  const _InvalidOperationError([this.message = '']);
}
