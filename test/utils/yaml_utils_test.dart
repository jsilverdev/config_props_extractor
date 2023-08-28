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

  group('YamlMagicExtension', () {
    late YamlMagic yamlMagic;

    setUp(() {
      yamlMagic = YamlMagic.fromString(
        content: "key: value",
        path: "path/to/file.yaml",
      );
    });

    test(
      'Should return a boolean if a key exists or not for a YamlMagic',
      () async {
        // act
        bool keyExists1 = yamlMagic.keyExists("key");
        bool keyExists2 = yamlMagic.keyExists("anotherKey");
        // assert
        expect(keyExists1, equals(true));
        expect(keyExists2, equals(false));
      },
    );

    test(
      'Should returns a boolean if the key have the value or not for a YamlMagic',
      () async {
        // act
        bool keyValueExists1 = yamlMagic.keyValueExists("key", "value");
        bool keyValueExists2 = yamlMagic.keyValueExists("key", "anotherValue");
        bool keyValueExists3 = yamlMagic.keyValueExists(
          "anotherKey",
          "anotherValue",
        );
        // assert
        expect(keyValueExists1, equals(true));
        expect(keyValueExists2, equals(false));
        expect(keyValueExists3, equals(false));
      },
    );
  });
}
