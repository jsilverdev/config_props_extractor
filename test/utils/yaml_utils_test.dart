import 'package:config_props_extractor/exceptions/exceptions.dart';
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
      'Should return normally if a key exists for a YamlMagic',
      () async {
        expect(
          // act
          () => yamlMagic.keyExistsOrFail("key"),
          // assert
          returnsNormally,
        );
      },
    );
    test(
      'Should throws YamlMissingKeyException if the key not exists in a YamlMagic',
      () async {
        expect(
          // act
          () => yamlMagic.keyExistsOrFail("anotherKey"),
          // assert
          throwsA(isA<YamlMissingKeyException>()),
        );
      },
    );

    test(
      'Should returns normally if the key have the value in YamlMagic',
      () async {
        expect(
          // act
          () => yamlMagic.keyValueExistsOrFail("key", "value"),
          // assert
          returnsNormally,
        );
      },
    );

    test(
      "Should throws a YamlKeyValueMissingException if the key doesn't have the value in YamlMagic",
      () async {
        expect(
          // act
          () => yamlMagic.keyValueExistsOrFail("key", "anotherValue"),
          // assert
          throwsA(isA<YamlKeyValueMissingException>()),
        );
      },
    );
  });
}
