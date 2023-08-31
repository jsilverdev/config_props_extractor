import 'dart:io';

import '../config/logger.dart';
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
        .map((file) => fromFileToYamlMagic(file))
        .where((yamlMagic) =>
            yamlMagic.originalMap['kind'] == kind.name &&
            yamlMagic.originalMap['data'] is KubeConfigData)
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
        final value = _formatPropertyValue(entry.value, settings);
        return "${entry.key}${settings.keyValueSeparator}$value";
      },
    ).reduce((value, element) => "$value${settings.entrySeparator}$element");
  }
}

String _formatPropertyValue(dynamic value, PropertiesStringConfig settings) {
  if (value == null && settings.valueNotDefined != null) {
    return settings.valueNotDefined!;
  }
  if (value != null &&
      settings.breakLine != PropertiesStringConfig.defaultBreakLine) {
    return value.toString().replaceAll(
          PropertiesStringConfig.defaultBreakLine,
          settings.breakLine,
        );
  }
  return value.toString();
}

KubeConfigData _decodeValues(KubeConfigData data) {
  return data.map((key, value) {
    final decodedValue = value == null
        ? null
        : tryBase64Decode(
            value,
            onFailed: () => log.w('The "$key" key can\'t be decoded'),
          );
    return MapEntry(key, decodedValue);
  });
}
