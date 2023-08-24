import 'dart:io';

import 'package:yaml_magic/yaml_magic.dart';

import '../models/kube_kind.dart';
import 'base64_utils.dart';
import 'yaml_utils.dart';

Map<String, dynamic> getDataPropFromKubeConfigDirectory(
  Directory directory,
  KubeConfigKind kind,
) {
  return directory
      .listSync()
      .whereType<File>()
      .where(
        (file) => hasYamlExtension(file.path),
      )
      .map(
        (file) => _getDataPropFromKubeConfigFile(file, kind),
      )
      .reduce(
        (value, element) => value..addAll(element),
      );
}

Map<String, dynamic> _getDataPropFromKubeConfigFile(
    File file, KubeConfigKind kind) {
  try {
    final yamlMagic = YamlMagic.fromString(
      content: file.readAsStringSync(),
      path: file.path,
    );

    yamlMagic
      ..keyExistsOrFail('kind')
      ..keyValueExistsOrFail('kind', kind.name);

    final map = yamlMagic.originalMap['data'] as Map<String, dynamic>;
    return kind.isOpaque ? _decodeOpaque(map) : map;
  } catch (e) {
    stderr.writeln(e);
    return Map<String, dynamic>.of({});
  }
}

Map<String, dynamic> _decodeOpaque(Map<String, dynamic> opaqueMap) {
  Map<String, dynamic> acc = Map.of({});
  for (var entry in opaqueMap.entries) {
    String? decodedValue = tryBase64Decode(entry.value);
    if (decodedValue != null) {
      acc.addAll({entry.key: decodedValue});
    }
  }
  return acc;
}
