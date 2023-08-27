import '../constants/constants.dart' as constants;
import 'package:process_run/process_run.dart';

import '../config/app_config.dart';
import '../utils/string_utils.dart';
import 'shell_service.dart';

class RepoService {
  final AppConfig _appConfig;
  final ShellService _shellService;

  const RepoService(this._appConfig, this._shellService);

  Future<String> _getGitCurrentBranch() async {
    print("Using current Branch");
    final res = await _shellService.runScript(
      constants.GIT_BRANCH_SHOW_CURRENT,
    );
    print("");
    return res.outLines.first;
  }

  Future<void> _gitCheckoutBranch(String branch) async {
    print('Checkout branch "$branch"');
    String safeBranch = shellArgument(branch);
    await _shellService.runScript(
      constants.GIT_CHECKOUT.format([safeBranch]),
    );
    print("");
  }

  Future<void> _gitRemoteHardReset(String branch) async {
    print('Hard reset to remote branch "$branch"');
    String safeBranch = shellArgument(branch);
    await _shellService.runScript(
      constants.GIT_REMOTE_HARD_RESET.format([
        safeBranch,
        !_appConfig.gitSSLEnabled ? "-c ${constants.GIT_SSL_VERIFY_FALSE}" : "",
      ]),
    );
    print("");
  }

  Future<void> setup() async {
    _shellService.moveShellTo(_appConfig.gitRepoPath);
    _shellService.checkExecutable(constants.GIT);
    //TODO: Validate if is a git folder

    if (_appConfig.gitBranch == "") {
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
}
