import 'dart:io';

import 'package:path/path.dart' as path;

import '../config/app_config.dart';
import '../models/kube_kind.dart';
import '../utils/date_utils.dart';
import '../utils/kube_utils.dart';

class TransformService {
  final AppConfig _appConfig;
  KubeConfigData kubeConfigData = {};

  TransformService(this._appConfig);

  void loadLKubeConfigMapsData() {
    final configMapDir = Directory(path.absolute(
      _appConfig.gitRepoPath,
      _appConfig.configMapsPath,
    ));

    kubeConfigData.addAllFromDir(
      configMapDir,
      kind: KubeConfigKind.configMap,
    );
  }

  void loadKubeSecretsData() {
    final secretsDir = Directory(path.absolute(
      _appConfig.gitRepoPath,
      _appConfig.secretsPath,
    ));

    kubeConfigData.addAllFromDir(
      secretsDir,
      kind: KubeConfigKind.secret,
    );
  }

  void saveKubeConfigDataAsTxt() {
    final file = File("PROPERTIES_FILE.txt");

    if (file.existsSync()) {
      file.deleteSync();
    }
    file.createSync();

    var sink = file.openWrite();
    sink.write("Properties file created at: ${formattedDate()}\n\n\n");
    sink.write(kubeConfigData.toFormattedString());
    sink.close();
  }

  void saveKubeConfigDataAsProperties() {
    kubeConfigData.toProperties().saveToFile(
          "application-local.properties",
        );
  }
}
