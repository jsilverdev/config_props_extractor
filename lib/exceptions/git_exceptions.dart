// coverage:ignore-file

import 'exceptions.dart';

abstract class GitException extends AppException {
  const GitException(super.message);
}

class IncorrectTopLevelGitPathException extends GitException {
  const IncorrectTopLevelGitPathException({
    required final String path,
  }) : super('"$path" path is not in the top level of the repository');
}

class GitRemoteToManyTimeException extends GitException {
  GitRemoteToManyTimeException({
    required final int minutes,
  }) : super(
            "Attempting to connect to remote repository took longer than expected ($minutes min)");
}
