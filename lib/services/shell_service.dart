import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:process_run/process_run.dart';

import '../exceptions/file_system_exceptions.dart';
import '../models/io_models.dart';

class ShellService {
  Shell _shell;
  int? _pid;
  final bool _isWindows;
  final ProcessRunSync _runProcessSync;
  final ProcessSignal _processSignal;

  ShellService({
    Shell? shell,
    bool? isWindows,
    ProcessRunSync? runProcessSync,
    ProcessSignal? processSignal,
  })  : _shell = shell ?? Shell(verbose: false),
        _isWindows = isWindows ?? Platform.isWindows,
        _runProcessSync = runProcessSync ?? Process.runSync,
        _processSignal = processSignal ?? ProcessSignal.sigint;

  void checkExecutable(String executable) {
    final execLocation = path.basename(executable) == executable
        ? _shell.options.environment.whichSync(executable)
        : null;

    if (execLocation == null) {
      throw ExecutableNotFoundInPathException(executable);
    }
  }

  Future<List<ProcessResult>> runScript(String script) {
    return _shell.run(script, onProcess: (process) {
      if (_pid == null) {
        _pid = process.pid;
        late final StreamSubscription<ProcessSignal> sub;
        sub = _processSignal.watch().listen((event) {
          sub.cancel();
          dispose();
        });
      }
    });
  }

  void moveShellTo(String path) {
    _shell = _shell.pushd(path);
  }

  void popShell() {
    _shell = _shell.popd();
  }

  void dispose() {
    if (_pid != null && _isWindows) {
      _runProcessSync('taskkill', ['/pid', '$_pid', '/f', '/t']);
      return;
    }
    _shell.kill();
  }

  String get currentPath => _shell.path;
}
