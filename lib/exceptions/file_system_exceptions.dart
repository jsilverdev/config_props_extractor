// coverage:ignore-file
import 'exceptions.dart';

abstract class FileSystemException extends AppException {
  const FileSystemException(super.message);
}

class ExecutableNotFoundInPathException extends FileSystemException {
  const ExecutableNotFoundInPathException(
    final String executable,
  ) : super("$executable is not found in the PATH. Check is it installed or in the PATH");
}

class FolderNotFoundException extends FileSystemException {
  FolderNotFoundException({
    required String path,
  }) : super('The current path "$path" not exists');
}
