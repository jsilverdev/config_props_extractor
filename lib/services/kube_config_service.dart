import 'dart:io';

import 'package:path/path.dart' as path;

import '../config/app_config.dart';
import '../config/logger.dart';
import '../models/kube_kind.dart';
import '../models/properties_string_config.dart';
import '../utils/date_utils.dart';
import '../utils/kube_utils.dart';

class KubeConfigService {
  final AppConfig _appConfig;
  final KubeConfigData _data;

  KubeConfigService(
    this._appConfig, {
    KubeConfigData? data,
  }) : _data = data ?? {};

  void loadConfigDatasFrom({required String gitPath}) {
    _validatePathAndAddToData(
      configPath: path.absolute(gitPath, _appConfig.configMapsPath),
      kind: KubeConfigKind.configMap,
    );

    _validatePathAndAddToData(
      configPath: path.absolute(gitPath, _appConfig.secretsPath),
      kind: KubeConfigKind.secret,
    );
  }

  void _validatePathAndAddToData({
    required String configPath,
    required KubeConfigKind kind,
  }) {
    final configDir = Directory(configPath);

    if (!configDir.existsSync()) {
      log.w('The path "${configDir.absolute.path}" not exits, skipping');
      return;
    }

    _data.addAllFromDirectory(
      configDir,
      kind: kind,
    );
  }

  void saveDataAsPropertiesFile({
    required String fileName,
    required PropertiesStringConfig config,
  }) {
    final String stringValue = _data.toPropertiesString(config);

    final file = _createFile(fileName);
    file.openSync(mode: FileMode.writeOnlyAppend)
      ..writeStringSync("# Created at: ${formattedDate()}\n\n")
      ..writeStringSync(stringValue)
      ..close();

    log.t("Saved file at: ${file.path}");
  }

  File _createFile(String fileName) {
    final file = File(fileName);

    if (file.existsSync()) {
      file.deleteSync();
    }
    file.createSync();

    return file;
  }
}
