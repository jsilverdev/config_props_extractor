import 'dart:io';

import 'package:meta/meta.dart';

import '../exceptions/exceptions.dart';
import 'package:process_run/process_run.dart';
import 'package:path/path.dart' as path;

class ShellService {
  Shell _shell;

  ShellService({Shell? shell}) : _shell = shell ?? Shell();

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

  @visibleForTesting
  String? get shellWorkingDir => _shell.options.workingDirectory;
}
