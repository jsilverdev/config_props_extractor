import 'dart:io' as io;

typedef Exit = dynamic Function(int exitCode);

typedef ProcessRunSync = io.ProcessResult Function(
  String executable,
  List<String> arguments,
);
