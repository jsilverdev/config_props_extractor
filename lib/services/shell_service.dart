import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:process_run/process_run.dart';

import '../exceptions/exceptions.dart';

class ShellService {
  Shell _shell;

  ShellService({Shell? shell}) : _shell = shell ?? Shell(verbose: false);

  void checkExecutable(String executable) {
    final execLocation = path.basename(executable) == executable
        ? _shell.options.environment.whichSync(executable)
        : null;

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

  String? get workingDir => _shell.options.workingDirectory;
}
