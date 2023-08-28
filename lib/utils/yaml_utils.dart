import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:yaml_magic/yaml_magic.dart';

const List<String> _yamlExtensions = [".yaml", ".yml"];

bool hasYamlExtension(String filePath) {
  return _yamlExtensions.contains(path.extension(filePath).toLowerCase());
}

YamlMagic toYamlMagic(File file) {
  return YamlMagic.fromString(
    content: file.readAsStringSync(),
    path: file.path,
  );
}

extension YamlMagicExtension on YamlMagic {
  bool keyExists(String key) {
    return originalMap[key] != null;
  }

  bool keyValueExists(String key, dynamic value) {
    return originalMap[key] == value;
  }
}
