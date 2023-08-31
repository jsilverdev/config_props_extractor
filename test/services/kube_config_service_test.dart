import 'dart:io';

import 'package:clock/clock.dart';
import 'package:config_props_extractor/constants/constants.dart';
import 'package:config_props_extractor/models/properties_string_config.dart';
import 'package:config_props_extractor/services/kube_config_service.dart';
import 'package:config_props_extractor/utils/kube_utils.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;

import '../helpers/mocks.dart';

void main() {
  late MockAppConfig mockAppConfig;
  late KubeConfigService kubeConfigService;

  setUp(() {
    mockAppConfig = MockAppConfig();
  });

  group('Load Configs', () {
    late KubeConfigData testData;
    setUp(() {
      testData = {};
      kubeConfigService = KubeConfigService(
        mockAppConfig,
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
        // act
        kubeConfigService.loadConfigDatas();
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
  });

  group("Save Data to File", () {
    final File testFile = File(
      path.absolute("test/_data/results", PROPERTIES_FILENAME),
    );

    setUp(() {
      if (testFile.existsSync()) testFile.deleteSync();
      kubeConfigService = KubeConfigService(
        mockAppConfig,
      );
    });

    tearDown(() {
      testFile.deleteSync();
    });

    void testSaveData() {
      //act
      withClock(
        Clock.fixed(DateTime(2022, 02, 02, 0, 0, 0)),
        () => kubeConfigService.saveDataAsPropertiesFile(
          fileName: testFile.path,
          config: PropertiesStringConfig.properties(),
        ),
      );

      // assert
      expect(testFile.existsSync(), true);
      expect(
          testFile.readAsStringSync(), "# Created at: 2022-02-02 0:00:00\n\n");
    }

    test(
      'Should save Data as Properties',
      () async {
        testSaveData();
      },
    );

    test(
      'Should delete file with same name and then save Data as Properties',
      () async {
        testFile.createSync();
        testSaveData();
      },
    );
  });
}
