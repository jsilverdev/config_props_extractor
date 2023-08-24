import 'package:process_run/process_run.dart';

import '../config/app_config.dart';
import 'shell_service.dart';

class RepoService {
  final AppConfig _appConfig;
  final ShellService _shellService;

  const RepoService(this._appConfig, this._shellService);

  Future<String> _getGitCurrentBranch() async {
    print("Using current Branch");
    final res = await _shellService.runScript("git branch --show-current");
    print("");
    return res.outLines.first;
  }

  Future<void> _gitCheckoutBranch(String branch) async {
    print('Checkout branch "$branch"');
    String safeBranch = shellArgument(branch);
    await _shellService.runScript('''
    git checkout $safeBranch
    ''');
    print("");
  }

  Future<void> _gitRemoteHardReset(String branch) async {
    print('Har reset to remote branch "$branch"');
    String safeBranch = shellArgument(branch);
    await _shellService.runScript('''
    git checkout $safeBranch
    git ${_gitArgs()} fetch origin $safeBranch
    git reset --hard origin/$safeBranch
    ''');
    print("");
  }

  Future<void> setup() async {
    _shellService.checkExecutable("git");
    _shellService.moveShellTo(_appConfig.gitRepoPath);

    if(_appConfig.gitBranch == "") {
      _appConfig.gitBranch = await _getGitCurrentBranch();
    }

    if (!_appConfig.gitForceRemote) {
      await _gitCheckoutBranch(_appConfig.gitBranch);
      return;
    }

    await _gitRemoteHardReset(_appConfig.gitBranch);
  }

  void dispose() {
    _shellService.dispose();
  }

  String _gitArgs() {
    return shellArguments([
      "-c",
      !_appConfig.gitSSLEnable ? "http.sslVerify=false" : "",
    ]);
  }
}
