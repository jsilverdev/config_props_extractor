import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:process_run/process_run.dart';

import '../config/app_config.dart';
import '../config/logger.dart';
import '../constants/constants.dart' as constants;
import '../exceptions/file_system_exceptions.dart';
import '../exceptions/git_exceptions.dart';
import '../utils/git_utils.dart';
import '../utils/string_utils.dart';
import 'shell_service.dart';

class RepoService {
  final AppConfig _appConfig;
  final ShellService _shellService;

  String _gitPath = "";
  bool _isCloned = false;
  final String _defaultReposFolder;

  RepoService(
    this._appConfig,
    this._shellService, {
    String? defaultParentFolder,
  }) : _defaultReposFolder = defaultParentFolder ?? constants.REPOS_FOLDER;

  Future<void> _overrideConfigGitBranchWithCurrentOnEmpty() async {
    if (_appConfig.gitBranch != "") return;

    log.w("You don't define an specific branch, using current branch");
    final res = await _shellService.runScript(
      constants.GIT_BRANCH_SHOW_CURRENT,
    );
    _appConfig.gitBranch = res.outLines.first;
  }

  Future<void> _moveToConfigGitBranch() async {
    String branch = _appConfig.gitBranch;
    log.i('Using branch "$branch"');
    String safeBranch = shellArgument(branch);
    try {
      await _shellService.runScript(
        constants.GIT_CHECKOUT.format([safeBranch]),
      );
    } on ShellException catch (e) {
      throw GitShellException(e);
    }
  }

  Future<void> _refreshLastChangesOnRemoteBranch() async {
    final String branch = _appConfig.gitBranch;
    log.i('Getting latests changes for "$branch" branch');
    try {
      final runScript = _shellService.runScript(
        constants.GIT_REFRESH_BRANCH.format([
          branch,
          _getRemoteConfig(),
        ]),
      );

      await _limitDurationForScript(runScript);
    } on ShellException catch (e) {
      throw GitShellException(e);
    }
  }

  Future<void> _overrideChangesWithRemote() async {
    final String branch = _appConfig.gitBranch;
    log.i('Override branch "$branch" with remote version');
    String safeBranch = shellArgument(branch);
    await _shellService.runScript(
      constants.GIT_OVERRIDE_WITH_REMOTE.format([safeBranch]),
    );
  }

  Future<void> _validateIfPathIsGitRepo() async {
    try {
      final res = await _shellService.runScript(constants.GIT_TOP_LEVEL_PATH);
      if (!path.equals(_gitPath, res.outLines.first)) {
        throw IncorrectTopLevelGitPathException(
          path: _gitPath,
        );
      }
    } on ShellException catch (e) {
      throw GitShellException(e);
    }
  }

  Future<bool> _tryCloneInPath({
    required String gitUrl,
    required String gitPath,
  }) async {
    if ((Directory(_gitPath).existsSync())) return false;

    try {
      final runScript = _shellService.runScript(constants.GIT_CLONE.format([
        gitUrl,
        gitPath,
        _getRemoteConfig(),
      ]));

      await _limitDurationForScript(runScript);
      log.i("Successfully cloned at: $gitPath");
      return true;
    } on ShellException catch (e) {
      throw GitShellException(e);
    }
  }

  Future<T> _limitDurationForScript<T>(Future<T> runScript) =>
      runScript.timeout(
        _appConfig.maxDuration,
        onTimeout: () {
          _shellService.dispose();
          throw GitRemoteToManyTimeException(
            minutes: _appConfig.maxDuration.inMinutes,
          );
        },
      );

  Future<void> _validateGitUrlAndClone() async {
    final bool isGitUrl = isValidGitUrl(_appConfig.gitRepoPath);

    if (!isGitUrl) {
      _gitPath = _appConfig.gitRepoPath;
      _isCloned = false;
      return;
    }

    _gitPath = path.absolute(
      _defaultReposFolder,
      extractGitPath(_appConfig.gitRepoPath),
    );

    _isCloned = await _tryCloneInPath(
      gitUrl: _appConfig.gitRepoPath,
      gitPath: _gitPath,
    );
  }

  void _validateGitPathAndMoveShell() {
    if (!Directory(_gitPath).existsSync()) {
      throw FolderNotFoundException(path: _gitPath);
    }
    _shellService.moveShellTo(_gitPath);
  }

  Future<String> setup() async {
    _shellService.checkExecutable(constants.GIT);

    log.i("Checking properties for: ${_appConfig.gitRepoPath}");

    await _validateGitUrlAndClone();

    _validateGitPathAndMoveShell();
    await _validateIfPathIsGitRepo();
    await _overrideConfigGitBranchWithCurrentOnEmpty();

    if (!_isCloned && _appConfig.gitForceRemote) {
      await _refreshLastChangesOnRemoteBranch();
    }

    await _moveToConfigGitBranch();

    if (_appConfig.gitForceRemote) {
      await _overrideChangesWithRemote();
    }

    return _gitPath;
  }

  String _getRemoteConfig() {
    final config = "{}".format([
      !_appConfig.gitSSLEnabled ? constants.GIT_SSL_VERIFY_FALSE : "",
    ]);
    if (config.isEmpty) return "";
    return "-c $config";
  }
}
