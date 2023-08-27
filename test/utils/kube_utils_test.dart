import 'dart:io';

import 'package:config_props_extractor/models/kube_kind.dart';
import 'package:config_props_extractor/utils/kube_utils.dart';
import 'package:properties/properties.dart';
import 'package:test/test.dart';

void main() {
  late KubeConfigData kubeConfigData;

  setUp(() {
    kubeConfigData = {};
  });

  test(
    'Should add config data props from KubeConfigMap files in a Directory',
    () async {
      // arrange
      // act
      kubeConfigData.addAllFromDir(
        Directory("test/_data/configs"),
        kind: KubeConfigKind.configMap,
      );
      // assert
      expect(kubeConfigData, isNotEmpty);
      expect(kubeConfigData, equals({'key': 'value'}));
    },
  );

  test(
    'Should add config data props from Secret files in a Directory',
    () async {
      // arrange
      // act
      kubeConfigData.addAllFromDir(
        Directory("test/_data/configs"),
        kind: KubeConfigKind.secret,
      );
      // assert
      expect(kubeConfigData, isNotEmpty);
      expect(kubeConfigData, equals({'key': 'value'}));
    },
  );

  test(
    'Should Convert to Formatted String',
    () async {
      // arrange
      kubeConfigData.addAll({"key" : "value", "key2" : "second\n_value"});
      // act
      final String actual = kubeConfigData.toFormattedString();
      // assert
      expect(actual, "key=value;key2=second_value");
    },
  );

  test(
    'Should Convert to Properties',
    () async {
      // arrange
      kubeConfigData.addAll({"key" : "value", "key2" : "second\n_value"});
      // act
      final Properties actual = kubeConfigData.toProperties();
      // assert
      expect(actual.keys, ["key", "key2"]);
      expect(actual.values, ["value", "second \\\n_value"]);
    },
  );
}
