// coverage:ignore-file
abstract class AppException implements Exception {
  final String _message;

  const AppException(this._message);

  @override
  String toString() => _message;
}

class ExecutableNotFoundInPathException extends AppException {
  const ExecutableNotFoundInPathException(
    final String executable,
  ) : super("$executable is not found in the PATH. Check is it installed or in the PATH");
}

class ConfigPropertyMissingException extends AppException {
  const ConfigPropertyMissingException({
    required final String property,
  }) : super('"$property" property is not defined int the .env file');
}

class InvalidValidGitPathException extends AppException {
  const InvalidValidGitPathException({
    required final String path
  }) : super('"$path" path is and invalid git repository');
}

class IncorrectTopLevelGitPathException extends AppException {
  const IncorrectTopLevelGitPathException({
    required final String path
  }) : super('"$path" path is not in the top level of the git repository');
}
