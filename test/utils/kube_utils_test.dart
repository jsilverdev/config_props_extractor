import 'dart:io';

import 'package:config_props_extractor/models/kube_kind.dart';
import 'package:config_props_extractor/utils/kube_utils.dart';
import 'package:test/test.dart';

void main() {
  test(
    'Should Get decoded Data from KubeConfigMap Directory',
    () async {
      // arrange
      // act
      final actual = getDataPropFromKubeConfigDirectory(
        Directory("test/_data/configs"),
        KubeConfigKind.configMap,
      );
      // assert
      expect(actual, isNotEmpty);
      expect(actual, equals(Map.of({'key': 'value'})));
    },
  );

  test(
    'Should Get decoded Data from KubeSecret Directory',
    () async {
      // arrange
      // act
      final actual = getDataPropFromKubeConfigDirectory(
        Directory("test/_data/configs"),
        KubeConfigKind.secret,
      );
      // assert
      expect(actual, isNotEmpty);
      expect(actual, equals(Map.of({'key': 'value'})));
    },
  );
}
