import 'dart:io';

import '../models/kube_kind.dart';
import '../models/properties_string_config.dart';
import 'base64_utils.dart';
import 'yaml_utils.dart';

typedef KubeConfigData = Map<String, dynamic>;

extension KubeConfigDataExtension on KubeConfigData {
  void addAllFromDirectory(
    Directory directory, {
    required KubeConfigKind kind,
  }) {
    directory
        .listSync()
        .whereType<File>()
        .where((file) => hasYamlExtension(file.path))
        .map((file) => toYamlMagic(file))
        .where(
          (yamlMagic) =>
              yamlMagic.keyValueExists('kind', kind.name) &&
              yamlMagic.keyExists('data'),
        )
        .forEach(
      (yamlMagic) {
        final data = yamlMagic.originalMap['data'] as KubeConfigData;
        addAll(!kind.isOpaque ? data : _decodeValues(data));
      },
    );
  }

  String toPropertiesString(PropertiesStringConfig settings) {
    if (isEmpty) return "";
    return entries.map(
      (entry) {
        final String value =
            settings.breakLine == PropertiesStringConfig.defaultBreakLine
                ? entry.value.toString()
                : entry.value.toString().replaceAll(
                      PropertiesStringConfig.defaultBreakLine,
                      settings.breakLine,
                    );

        return "${entry.key}${settings.keyValueSeparator}$value";
      },
    ).reduce((value, element) => "$value${settings.entrySeparator}$element");
  }
}

KubeConfigData _decodeValues(KubeConfigData data) {
  if (data.isEmpty) return {};

  final KubeConfigData acc = {};
  for (var entry in data.entries) {
    String? decodedValue = tryBase64Decode(entry.value);
    if (decodedValue == null) continue;
    acc.addAll({entry.key: decodedValue});
  }
  return acc;
}
