import 'dart:io';

import '../exceptions/exceptions.dart';
import 'package:process_run/process_run.dart';

class ShellService {
  final Shell _shell = Shell();

  void checkExecutable(String executable) async {
    print("Check if $executable is in the PATH");

    final execLocation = whichSync(executable);

    if (execLocation == null) {
      throw ExecutableNotFound(executable);
    }
  }

  Future<List<ProcessResult>> run(String script) {
    return _shell.run(script);
  }
}
