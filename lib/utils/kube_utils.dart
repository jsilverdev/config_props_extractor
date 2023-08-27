import 'dart:io';

import 'package:properties/properties.dart';
import 'package:yaml_magic/yaml_magic.dart';

import '../models/kube_kind.dart';
import 'base64_utils.dart';
import 'yaml_utils.dart';

typedef KubeConfigData = Map<String, dynamic>;

extension KubeConfigDataExtension on KubeConfigData {
  KubeConfigData _getDataPropFromKubeConfigDirectory(
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

  KubeConfigData _getDataPropFromKubeConfigFile(
    File file,
    KubeConfigKind kind,
  ) {
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

  KubeConfigData _decodeOpaque(
    Map<String, dynamic> opaqueMap,
  ) {
    Map<String, dynamic> acc = Map.of({});
    for (var entry in opaqueMap.entries) {
      String? decodedValue = tryBase64Decode(entry.value);
      if (decodedValue != null) {
        acc.addAll({entry.key: decodedValue});
      }
    }
    return acc;
  }

  void addAllFromDir(
    Directory dir, {
    required KubeConfigKind kind,
  }) {
    return addAll(
      _getDataPropFromKubeConfigDirectory(dir, kind),
    );
  }

  String toFormattedString() {
    return entries.map(
      (entry) {
        final String value = entry.value.toString().replaceAll("\n", "");
        return "${entry.key}=$value";
      },
    ).reduce((value, element) => "$value;$element");
  }

  Map<String, String> _toMapProperties(
    Map<String, dynamic> data,
  ) {
    return data.map(
      (key, value) => MapEntry(
        key,
        value.toString().replaceAll("\n", ' \\\n'),
      ),
    );
  }

  Properties toProperties() {
    return Properties.fromMap(
      _toMapProperties(this),
    );
  }
}
