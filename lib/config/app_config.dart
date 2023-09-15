import 'package:dotenv/dotenv.dart';

import '../constants/constants.dart' as constants;
import '../exceptions/config_exceptions.dart';
import '../models/config_property.dart';
import '../utils/string_utils.dart';

class AppConfig {
  final DotEnv _dotEnv;

  // coverage:ignore-start
  AppConfig({
    DotEnv? dotEnv,
  }) : _dotEnv = dotEnv ?? (DotEnv(includePlatformEnvironment: true)..load());
  // coverage:ignore-end

  String get gitRepoPath => _dotEnv.getOrElse(
        ConfigProperty.gitRepoPath.value,
        () => throw ConfigPropertyMissingException(
          property: ConfigProperty.gitRepoPath.value,
        ),
      );

  bool get gitForceRemote => _dotEnv
      .getOrElse(
        ConfigProperty.gitForceRemote.value,
        () => 'false',
      )
      .toBoolean();

  bool get gitSSLEnabled => _dotEnv
      .getOrElse(
        ConfigProperty.gitSSLEnabled.value,
        () => 'true',
      )
      .toBoolean();

  String get gitBranch => _dotEnv.getOrElse(
        ConfigProperty.gitBranch.value,
        () => "",
      );

  set gitBranch(String gitBranch) {
    _dotEnv.addAll({
      ConfigProperty.gitBranch.value: gitBranch,
    });
  }

  String get configMapsPath => _dotEnv.getOrElse(
        ConfigProperty.configMapsPath.value,
        () => constants.DEFAULT_CONFIG_MAP_PATH,
      );

  String get secretsPath => _dotEnv.getOrElse(
        ConfigProperty.secretsPath.value,
        () => constants.DEFAULT_CONFIG_SECRET_PATH,
      );

  Duration get maxDuration => Duration(
        minutes: _dotEnv[ConfigProperty.maxDurationInMin.value]?.toInt(2) ?? 2,
      );
}
