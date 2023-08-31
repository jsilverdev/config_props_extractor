import 'dart:io';

import 'package:config_props_extractor/utils/yaml_utils.dart';
import 'package:test/test.dart';
import 'package:yaml_magic/yaml_magic.dart';

void main() {
  test(
    'Should Check if filePath has a valid yaml extension',
    () async {
      // arrange
      String yamlFilePath = "/path/to/example.yaml";
      String ymlFilePath = "/path/to/example.YML";

      // act
      bool isYaml = hasYamlExtension(yamlFilePath);
      bool isYml = hasYamlExtension(ymlFilePath);

      // assert
      expect(isYaml, equals(true));
      expect(isYml, equals(true));
    },
  );

  test(
    'Should Convert YamlMagic From File',
    () async {
      // arrange
      final file = File("test/_data/configs/config_map.yaml");
      // act
      YamlMagic yamlMagic = fromFileToYamlMagic(file);
      // assert
      expect(yamlMagic, isNotNull);
      expect(yamlMagic.originalMap, {
        "kind": "ConfigMap",
        "data": {
          "key": "value",
          "empty_key": null,
          "null_key": null,
        }
      });
    },
  );
}
