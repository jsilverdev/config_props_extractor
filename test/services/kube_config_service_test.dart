import 'dart:io';

import 'package:clock/clock.dart';
import 'package:config_props_extractor/models/properties_string_config.dart';
import 'package:config_props_extractor/services/kube_config_service.dart';
import 'package:config_props_extractor/utils/kube_utils.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../helpers/mocks.dart';

void main() {
  late MockAppConfig mockAppConfig;
  late KubeConfigService kubeConfigService;
  late MockShellService mockShellService;

  setUp(() {
    mockAppConfig = MockAppConfig();
    mockShellService = MockShellService();
  });

  group('Load Configs', () {
    late KubeConfigData testData;
    setUp(() {
      testData = {};
      kubeConfigService = KubeConfigService(
        mockAppConfig,
        mockShellService,
        data: testData,
      );
      when(() => mockAppConfig.gitRepoPath).thenReturn(
        "test/_data",
      );
    });

    test(
      'Should load Config Data from Directory',
      () async {
        // arrange
        when(() => mockAppConfig.configMapsPath).thenReturn("configs");
        when(() => mockAppConfig.secretsPath).thenReturn("configs");
        when(() => mockShellService.currentPath).thenReturn("test/_data");
        // act
        kubeConfigService.loadConfigDatasFromCurrentPath();
        // assert
        expect(testData, isNotEmpty);
        expect(testData, {
          "key": "value",
          "empty_key": null,
          "null_key": null,
          "secret_key": "value",
          "another_key": null,
        });
      },
    );
    test(
      "Should don't fail if the folders not exists",
      () async {
        // arrange
        when(() => mockAppConfig.configMapsPath).thenReturn("configNotExists");
        when(() => mockAppConfig.secretsPath).thenReturn("secretNotExists");
        when(() => mockShellService.currentPath).thenReturn("test/_data");
        // act
        kubeConfigService.loadConfigDatasFromCurrentPath();
        // assert
        expect(testData, isEmpty);
      },
    );
  });

  group("Save Data to File", () {
    final File fileShouldExists = File(
      path.absolute("test/_data/results/file_that_exists"),
    );
    final File fileShouldNotExists = File(
      path.absolute("test/_data/results/file_that_not_exists"),
    );

    void clearFileIfExists(File file) {
      if (file.existsSync()) file.deleteSync();
    }

    setUp(() {
      clearFileIfExists(fileShouldExists);
      clearFileIfExists(fileShouldNotExists);
      kubeConfigService = KubeConfigService(mockAppConfig, mockShellService);
    });

    tearDown(() {
      clearFileIfExists(fileShouldExists);
      clearFileIfExists(fileShouldNotExists);
    });

    void testSaveData(File file) {
      //act
      withClock(
        Clock.fixed(DateTime(2022, 02, 02, 0, 0, 0)),
        () => kubeConfigService.saveDataAsPropertiesFile(
          fileName: file.path,
          config: PropertiesStringConfig.properties(),
        ),
      );

      // assert
      expect(file.existsSync(), true);
      expect(
        file.readAsStringSync(),
        "# Created at: 2022-02-02 0:00:00\n\n",
      );
    }

    test(
      'Should save Data as Properties',
      () async {
        testSaveData(fileShouldNotExists);
      },
    );

    test(
      'Should delete file with same name and then save Data as Properties',
      () async {
        if (!fileShouldExists.existsSync()) fileShouldExists.createSync();
        testSaveData(fileShouldExists);
      },
    );
  });
}
