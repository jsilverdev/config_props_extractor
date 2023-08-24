import 'package:path/path.dart' as path;
import 'package:yaml_magic/yaml_magic.dart';

import '../exceptions/exceptions.dart';

const List<String> _yamlExtensions = [".yaml", ".yml"];

bool hasYamlExtension(String filePath) {
  return _yamlExtensions.contains(path.extension(filePath).toLowerCase());
}

extension YamlMagicExtension on YamlMagic {
  void keyExistsOrFail(String key) {
    if (this[key] == null) {
      throw YamlMissingKeyException(
        key: key,
        path: this.path,
      );
    }
  }

  void keyValueExistsOrFail(String key, value) {
    if (this[key] != value) {
      throw YamlKeyValueMissingException(
        key: key,
        value: value,
        path: this.path,
      );
    }
  }
}
