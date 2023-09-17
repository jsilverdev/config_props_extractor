// coverage:ignore-file
import 'config/app_config.dart';
import 'constants/constants.dart' as constants;
import 'models/properties_string_config.dart';
import 'services/kube_config_service.dart';
import 'services/repo_service.dart';
import 'services/shell_service.dart';

Future<void> runApp(List<String> arguments) async {
  final appConfig = AppConfig();

  final shellService = ShellService();
  final repoService = RepoService(
    appConfig,
    shellService,
  );

  final gitRepo = repoService.preRequisites();
  await repoService.tryCloning(gitRepo);
  await repoService.checkGitPath(gitRepo);
  await repoService.tryFetchingChanges(gitRepo);
  await repoService.applyChanges(gitRepo);

  final kubeConfigService = KubeConfigService(appConfig, shellService);
  kubeConfigService
    ..loadConfigDatasFromCurrentPath()
    ..saveDataAsPropertiesFile(
      fileName: constants.PROPERTIES_FILENAME,
      config: PropertiesStringConfig.properties(),
    )
    ..saveDataAsPropertiesFile(
      fileName: constants.TXT_FILENAME,
      config: PropertiesStringConfig.txt(),
    );
}
