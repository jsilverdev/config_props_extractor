abstract class AppException implements Exception {
  final String _message;

  const AppException(this._message);

  @override
  String toString() => _message;
}

class ExecutableNotFound extends AppException {
  ExecutableNotFound(final String executable)
      : super("$executable is not found in the PATH or is not installed");
}
