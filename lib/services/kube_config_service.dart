import 'dart:io';

import 'package:path/path.dart' as path;

import '../config/app_config.dart';
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
  })  : _data = data ?? {};

  void loadConfigDatas() {
    _loadConfigData(
      _appConfig.configMapsPath,
      KubeConfigKind.configMap,
    );
    _loadConfigData(
      _appConfig.secretsPath,
      KubeConfigKind.secret,
    );
  }

  void _loadConfigData(String configPath, KubeConfigKind kind) {
    final configDir = Directory(path.absolute(
      _appConfig.gitRepoPath,
      configPath,
    ));

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

    _createFile(fileName).openSync(mode: FileMode.writeOnlyAppend)
      ..writeStringSync("# Created at: ${formattedDate()}\n\n")
      ..writeStringSync(stringValue)
      ..close();
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
