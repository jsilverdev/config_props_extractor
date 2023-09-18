import 'dart:async';

import 'package:path/path.dart' as path;
import 'package:process_run/process_run.dart';

import '../config/app_config.dart';
import '../config/logger.dart';
import '../constants/constants.dart' as constants;
import '../exceptions/exceptions.dart';
import '../exceptions/file_system_exceptions.dart';
import '../exceptions/git_exceptions.dart';
import '../models/git_repo.dart';
import '../utils/git_utils.dart';
import '../utils/string_utils.dart';
import 'shell_service.dart';

class RepoService {
  final AppConfig _appConfig;
  final ShellService _shellService;
  final String _reposFolder;

  RepoService(
    this._appConfig,
    this._shellService, {
    String? reposFolder,
  }) : _reposFolder = reposFolder ?? constants.REPOS_FOLDER;

  GitRepo _createGitRepo(String gitPathOrUrl) {
    String gitPath = gitPathOrUrl;
    String gitUrl = "";
    final bool isGitUrl = isValidGitUrl(gitPathOrUrl);

    if (isGitUrl) {
      gitPath = path.join(
        _reposFolder,
        extractPathFromGitUrl(gitPathOrUrl),
      );
      gitUrl = gitPathOrUrl;
    }

    return GitRepo(
      gitPath: gitPath,
      gitUrl: gitUrl,
      branch: _appConfig.gitBranch,
      toClone: isGitUrl,
    );
  }

  GitRepo preRequisites() {
    _shellService.checkExecutable(constants.GIT);

    log.i("Checking properties for: ${_appConfig.gitRepoPath}");

    return _createGitRepo(_appConfig.gitRepoPath);
  }

  Future<void> tryCloning(final GitRepo gitRepo) async {
    if (!gitRepo.toClone) return;

    await _deleteIfRepoHasNoCommits(gitRepo);
    if (gitRepo.existsOnLocal) return;

    final runScript = _shellService.runScript(constants.GIT_CLONE.format([
      gitRepo.gitUrl,
      gitRepo.gitDir.absolute.path,
      _getRemoteConfig(),
    ]));

    await _timeoutFor(runScript);
    log.i("Successfully cloned at: ${gitRepo.gitDir.absolute.path}");
    gitRepo.wasCloned = true;
  }

  // * Necessary for windows
  Future<void> _deleteIfRepoHasNoCommits(GitRepo gitRepo) async {
    _shellService.moveShellTo(gitRepo.gitDir.path);
    try {
      if (gitRepo.existsOnLocal) {
        await _shellService.runScript(constants.GIT_REV_PARSE_HEAD);
      }
    } on AppShellException {
      gitRepo.gitDir.deleteSync(recursive: true);
    }
    _shellService.popShell();
  }

  Future<void> checkGitPath(final GitRepo gitRepo) async {
    final String gitPath = gitRepo.gitDir.path;
    if (!gitRepo.existsOnLocal) {
      throw FolderNotFoundException(path: gitPath);
    }

    _shellService.moveShellTo(gitPath);

    final res = await _shellService.runScript(constants.GIT_TOP_LEVEL_PATH);
    if (!path.equals(gitPath, res.outLines.first)) {
      throw IncorrectTopLevelGitPathException(
        path: gitPath,
      );
    }
  }

  Future<void> tryFetchingChanges(final GitRepo gitRepo) async {
    final bool forceRemote = _appConfig.gitForceRemote;
    await _validateGitBranch(gitRepo);
    final bool forceRefresh = gitRepo.toClone && !gitRepo.wasCloned;

    if (!forceRemote && !forceRefresh) return;

    log.i('Getting latests changes for "${gitRepo.branch}" branch');

    final runScript = _shellService.runScript(
      constants.GIT_REFRESH_BRANCH.format([
        gitRepo.branch,
        _getRemoteConfig(),
      ]),
    );

    await _timeoutFor(runScript);
  }

  Future<void> applyChanges(final GitRepo gitRepo) async {
    log.i('Using branch "${gitRepo.branch}"');
    await _shellService.runScript(
      constants.GIT_CHECKOUT.format([gitRepo.branch]),
    );

    // log.i('Override branch "${gitRepo.branch}" with remote version');
    await _shellService.runScript(
      constants.GIT_OVERRIDE_WITH_REMOTE.format([gitRepo.branch]),
    );
  }

  Future<void> _validateGitBranch(final GitRepo gitRepo) async {
    if (gitRepo.branch != "") return;

    log.w("You don't define an specific branch, using current branch");

    final res = await _shellService.runScript(
      constants.GIT_BRANCH_SHOW_CURRENT,
    );
    gitRepo.branch = res.outLines.first;
  }

  Future<T> _timeoutFor<T>(Future<T> runScript) => runScript.timeout(
        _appConfig.maxDuration,
        onTimeout: () {
          _shellService.dispose();
          throw GitRemoteToManyTimeException(
            minutes: _appConfig.maxDuration.inMinutes,
          );
        },
      );

  String _getRemoteConfig() {
    final config = "{}".format([
      !_appConfig.gitSSLEnabled ? constants.GIT_SSL_VERIFY_FALSE : "",
    ]);
    if (config.isEmpty) return "";
    return "-c $config";
  }
}
