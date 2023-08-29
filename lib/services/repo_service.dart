import 'package:process_run/process_run.dart';

import '../config/app_config.dart';
import '../constants/constants.dart' as constants;
import '../logger/app_logger.dart';
import '../utils/string_utils.dart';
import 'shell_service.dart';

class RepoService {
  final AppConfig _appConfig;
  final ShellService _shellService;

  const RepoService(this._appConfig, this._shellService);

  Future<String> _getGitCurrentBranch() async {
    final res = await _shellService.runScript(
      constants.GIT_BRANCH_SHOW_CURRENT,
    );
    return res.outLines.first;
  }

  Future<void> _gitCheckoutBranch(String branch) async {
    String safeBranch = shellArgument(branch);
    await _shellService.runScript(
      constants.GIT_CHECKOUT.format([safeBranch]),
    );
  }

  Future<void> _gitRemoteHardReset(String branch) async {
    String safeBranch = shellArgument(branch);
    await _shellService.runScript(
      constants.GIT_REMOTE_HARD_RESET.format([
        safeBranch,
        !_appConfig.gitSSLEnabled ? "-c ${constants.GIT_SSL_VERIFY_FALSE}" : "",
      ]),
    );
  }

  Future<void> setup() async {
    logger.i("Checking properties for: ${_appConfig.gitRepoPath}");
    _shellService.moveShellTo(_appConfig.gitRepoPath);

    logger.i("Checking if {} is installed".format([constants.GIT]));
    _shellService.checkExecutable(constants.GIT);

    //TODO: Validate if is a git folder

    if (_appConfig.gitBranch == "") {
      logger.w("You don't define an specific branch, using current branch");
      _appConfig.gitBranch = await _getGitCurrentBranch();
    }

    logger.i('Using branch "{}"'.format(
      [_appConfig.gitBranch],
    ));
    if (!_appConfig.gitForceRemote) {
      await _gitCheckoutBranch(_appConfig.gitBranch);
      return;
    }

    logger.i('Making hard reset of branch {}'.format(
      [_appConfig.gitBranch],
    ));
    await _gitRemoteHardReset(_appConfig.gitBranch);
  }

  void dispose() {
    _shellService.dispose();
  }
}
