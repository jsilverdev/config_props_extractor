import 'package:config_props_extractor/config/app_config.dart';
import 'package:config_props_extractor/constants/constants.dart' as constants;
import 'package:config_props_extractor/exceptions/config_exceptions.dart';
import 'package:config_props_extractor/models/config_property.dart';
import 'package:config_props_extractor/utils/string_utils.dart';
import 'package:dotenv/dotenv.dart';
import 'package:test/test.dart';

void main() {
  late DotEnv dotEnv;
  late AppConfig appConfig;

  setUp(() {
    dotEnv = DotEnv();
    appConfig = AppConfig(dotEnv: dotEnv);
  });

  test('Get properties Success', () async {
    final gitRepoPath = "path";
    final gitForceRemote = "true";
    final gitSSLEnabled = "true";
    final gitBranch = "branch";
    final configMapsPath = "config_map_path";
    final secretsPath = "secret_path";
    final maxDurationInMin = "100";

    Map<String, String> dotEnvProps = Map.of({
      ConfigProperty.gitRepoPath.value: gitRepoPath,
      ConfigProperty.gitForceRemote.value: gitForceRemote,
      ConfigProperty.gitSSLEnabled.value: gitSSLEnabled,
      ConfigProperty.gitBranch.value: gitBranch,
      ConfigProperty.configMapsPath.value: configMapsPath,
      ConfigProperty.secretsPath.value: secretsPath,
      ConfigProperty.maxDurationInMin.value: maxDurationInMin
    });
    dotEnv.addAll(dotEnvProps);

    expect(appConfig.gitRepoPath, equals(gitRepoPath));
    expect(appConfig.gitForceRemote, equals(gitForceRemote.toBoolean()));
    expect(appConfig.gitSSLEnabled, equals(gitSSLEnabled.toBoolean()));
    expect(appConfig.gitBranch, equals(gitBranch));
    expect(appConfig.configMapsPath, equals(configMapsPath));
    expect(appConfig.secretsPath, equals(secretsPath));
    expect(
      appConfig.maxDuration,
      equals(Duration(minutes: maxDurationInMin.toInt())),
    );
  });

  test('Fail get properties', () async {
    expect(
      () => appConfig.gitRepoPath,
      throwsA(isA<ConfigPropertyMissingException>()),
    );
    expect(
      appConfig.gitForceRemote,
      equals(false),
    );
    expect(
      appConfig.gitSSLEnabled,
      equals(true),
    );
    expect(
      appConfig.gitBranch,
      equals(""),
    );
    expect(
      appConfig.configMapsPath,
      equals(constants.DEFAULT_CONFIG_MAP_PATH),
    );
    expect(
      appConfig.secretsPath,
      equals(constants.DEFAULT_CONFIG_SECRET_PATH),
    );
    expect(
      appConfig.maxDuration,
      Duration(minutes: 2),
    );
  });
}
