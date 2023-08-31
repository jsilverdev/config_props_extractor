import 'dart:io';

import 'package:config_props_extractor/models/kube_kind.dart';
import 'package:config_props_extractor/models/properties_string_config.dart';
import 'package:config_props_extractor/utils/kube_utils.dart';
import 'package:test/test.dart';

void main() {
  late KubeConfigData kubeConfigData;

  group('group name', () {
    setUp(() {
      kubeConfigData = {};
    });

    test(
      'Should add config data props from ConfigMap files in a Directory',
      () async {
        // arrange
        // act
        kubeConfigData.addAllFromDirectory(
          Directory("test/_data/configs"),
          kind: KubeConfigKind.configMap,
        );
        // assert
        expect(kubeConfigData, isNotEmpty);
        expect(
            kubeConfigData,
            equals({
              'key': 'value',
              "empty_key": null,
              "null_key": null,
            }));
      },
    );

    test(
      'Should add config data props from Secret files in a Directory',
      () async {
        // arrange
        // act
        kubeConfigData.addAllFromDirectory(
          Directory("test/_data/configs"),
          kind: KubeConfigKind.secret,
        );
        // assert
        expect(kubeConfigData, isNotEmpty);
        expect(
            kubeConfigData,
            equals({
              'secret_key': 'value',
              "empty_key": null,
              "another_key": null
            }));
      },
    );
  });

  group("toProperties", () {
    setUp(() {
      kubeConfigData = {
        "key": "value",
        "key2": "second\n_value",
        "empty_value": null
      };
    });

    test(
      'Should Convert to Properties String',
      () async {
        // act
        final String actual = kubeConfigData
            .toPropertiesString(PropertiesStringConfig.properties());
        // assert
        expect(actual, "key=value\nkey2=second \\\n_value\nempty_value=");
      },
    );

    test(
      'Should Convert to TXT String',
      () async {
        // act
        final String actual =
            kubeConfigData.toPropertiesString(PropertiesStringConfig.txt());
        // assert
        expect(actual, "key=value;key2=second_value;empty_value=");
      },
    );

    test(
      'Should Convert to String with default breakLine',
      () async {
        // act
        final String actual = kubeConfigData.toPropertiesString(
            PropertiesStringConfig.custom(
                entrySeparator: " _ ", keyValueSeparator: " * "));
        // assert
        expect(
            actual, "key * value _ key2 * second\n_value _ empty_value * null");
      },
    );

    test(
      'Should Convert to String with Empty Map',
      () async {
        // arrange
        kubeConfigData = {};
        // act
        final String actual = kubeConfigData
            .toPropertiesString(PropertiesStringConfig.properties());
        // assert
        expect(actual, "");
      },
    );
  });
}
