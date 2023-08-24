import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:properties/properties.dart';

import '../config/app_config.dart';
import '../models/kube_kind.dart';
import '../utils/kube_utils.dart';

class TransformService {
  final AppConfig _appConfig;
  Map<String, dynamic> kubeConfigData = Map.of({});

  TransformService(this._appConfig);

  void loadLKubeConfigMapsData() {
    final configMapDir = Directory(path.absolute(
      _appConfig.gitRepoPath,
      _appConfig.configMapsPath,
    ));

    kubeConfigData.addAll(getDataPropFromKubeConfigDirectory(
      configMapDir,
      KubeConfigKind.configMap,
    ));
  }

  void loadKubeSecretsData() {
    final secretsDir = Directory(path.absolute(
      _appConfig.gitRepoPath,
      _appConfig.secretsPath,
    ));

    kubeConfigData.addAll(getDataPropFromKubeConfigDirectory(
      secretsDir,
      KubeConfigKind.secret,
    ));
  }

  void saveKubeConfigDataAsTxt() {
    final file = File(_getFileName(".txt"));

    if (file.existsSync()) {
      file.deleteSync();
    }
    file.createSync();

    var sink = file.openWrite();
    sink.write(_getStringFromKubeConfigData(kubeConfigData));
    sink.close();
  }

  String _getStringFromKubeConfigData(Map<String, dynamic> data) {
    return data.entries
        .map(
          (entry) =>
              "${entry.key}=${entry.value.toString().replaceAll("\n", "")}",
        )
        .reduce((value, element) => "$value;$element");
  }

  String _getFileName(String extension) {
    final String baseNameFolder = path.basename(_appConfig.gitRepoPath);
    final String branch = _appConfig.gitBranch.toUpperCase();
    return "${branch}_$baseNameFolder$extension";
  }

  Map<String, String> _getMapForProperties(Map<String, dynamic> data) {
    return data.map((key, value) => MapEntry(key, value.toString().replaceAll("\n", ' \\\n')));
  }

  void saveKubeConfigDataAsProperties() {
    final prop = Properties.fromMap(_getMapForProperties(kubeConfigData));
    prop.saveToFile(
        "application-${_appConfig.gitBranch.toLowerCase()}.properties");
  }
}
