import 'package:config_props_extractor/config/app_config.dart';
import 'package:config_props_extractor/exceptions/exceptions.dart';
import 'package:config_props_extractor/models/config_property.dart';
import 'package:config_props_extractor/utils/string_utils.dart';
import 'package:dotenv/dotenv.dart';
import 'package:test/test.dart';
import 'package:config_props_extractor/constants/constants.dart' as constants;

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

    Map<String, String> dotEnvProps = Map.of({
      ConfigProperty.gitRepoPath.value: gitRepoPath,
      ConfigProperty.gitForceRemote.value: gitForceRemote,
      ConfigProperty.gitSSLEnabled.value: gitSSLEnabled,
      ConfigProperty.gitBranch.value: gitBranch,
      ConfigProperty.configMapsPath.value: configMapsPath,
      ConfigProperty.secretsPath.value: secretsPath,
    });
    dotEnv.addAll(dotEnvProps);

    expect(appConfig.gitRepoPath, equals(gitRepoPath));
    expect(appConfig.gitForceRemote, equals(gitForceRemote.toBoolean()));
    expect(appConfig.gitSSLEnabled, equals(gitSSLEnabled.toBoolean()));
    expect(appConfig.gitBranch, equals(gitBranch));
    expect(appConfig.configMapsPath, equals(configMapsPath));
    expect(appConfig.secretsPath, equals(secretsPath));
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
  });

  test(
    'Should set value to gitBranch',
    () async {
      // arrange
      appConfig.gitBranch = "test";
      // act
      expect(appConfig.gitBranch, equals("test"));
      // assert
    },
  );
}
