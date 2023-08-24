import 'package:dotenv/dotenv.dart';

import '../constants/constants.dart' as constants;
import '../exceptions/exceptions.dart';
import '../utils/string_utils.dart';

class AppConfig {
  final DotEnv _dotEnv;

  AppConfig({DotEnv? dotEnv})
      : _dotEnv = dotEnv ?? (DotEnv(includePlatformEnvironment: true)..load());

  String get gitRepoPath => _dotEnv.getOrElse(
        "GIT_REPO_PATH",
        () => throw ConfigPropertyMissingException(property: "GIT_REPO_PATH"),
      );

  bool get gitForceRemote =>
      _dotEnv.getOrElse("GIT_FORCE_REMOTE", () => 'false').toBoolean();

  bool get gitSSLEnable => _dotEnv
      .getOrElse(
        "GIT_SSL_ENABLED",
        () => 'true',
      )
      .toBoolean();

  String get gitBranch => _dotEnv.getOrElse("GIT_BRANCH", () => "");

  set gitBranch(String gitBranch) {
    _dotEnv.addAll({"GIT_BRANCH": gitBranch});
  }

  String get configMapsPath => _dotEnv.getOrElse(
        "CONFIG_MAPS_PATH",
        () => constants.DEFAULT_CONFIG_MAP_PATH,
      );

  String get secretsPath => _dotEnv.getOrElse(
        "SECRETS_PATH",
        () => constants.DEFAULT_CONFIG_SECRET_PATH,
      );
}
