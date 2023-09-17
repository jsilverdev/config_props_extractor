// coverage:ignore-file
import 'package:process_run/process_run.dart';

abstract class AppException implements Exception {
  final String _message;

  const AppException(this._message);

  @override
  String toString() => _message;
}

class AppShellException extends AppException {
  AppShellException(ShellException e) : super(e.result?.errText ?? e.message);
}
