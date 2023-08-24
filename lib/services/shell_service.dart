import 'dart:io';

import '../exceptions/exceptions.dart';
import 'package:process_run/process_run.dart';

class ShellService {
  Shell _shell;

  ShellService({Shell? shell}) : _shell = shell ?? Shell();

  void checkExecutable(String executable) async {
    final execLocation = whichSync(executable);

    if (execLocation == null) {
      throw ExecutableNotFoundInPathException(executable);
    }
  }

  Future<List<ProcessResult>> runScript(String script) {
    return _shell.run(script);
  }

  void moveShellTo(String path) {
    _shell = _shell.pushd(path);
  }

  void popShell() {
    _shell = _shell.popd();
  }

  void dispose() {
    _shell.kill();
  }
}
