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

abstract class GitException extends AppException {
  const GitException(super.message);
}

class InvalidValidGitPathException extends GitException {
  const InvalidValidGitPathException({required final String path})
      : super('"$path" path is and invalid git repository');
}

class IncorrectTopLevelGitPathException extends GitException {
  const IncorrectTopLevelGitPathException({
    required final String path,
  }) : super('"$path" path is not in the top level of the git repository');
}

class InvalidGitLocalBranchException extends GitException {
  InvalidGitLocalBranchException({
    required final String branch,
  }) : super(
            'The selected branch "$branch" is not valid for the git repository');
}

class InvalidGitRemoteBranchException extends GitException {
  InvalidGitRemoteBranchException({
    required final String branch,
  }) : super(
            'The selected branch "$branch" is not in the remote git repository');
}

class GitRemoteToManyTimeException extends GitException {
  GitRemoteToManyTimeException({
    required final int minutes,
  }) : super(
            "Attempting to connect to remote repository took longer than expected ($minutes min)");
}
