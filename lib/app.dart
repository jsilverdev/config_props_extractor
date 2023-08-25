import 'config/app_config.dart';
import 'services/repo_service.dart';
import 'services/shell_service.dart';
import 'services/transform_service.dart';

void runApp(List<String> arguments) async {
  final appConfig = AppConfig();

  final repoService = RepoService(
    appConfig,
    ShellService(),
  );

  await repoService.setup();
  repoService.dispose();

  final transformService = TransformService(appConfig);
  transformService
    ..loadLKubeConfigMapsData()
    ..loadKubeSecretsData()
    ..saveKubeConfigDataAsTxt()
    ..saveKubeConfigDataAsProperties();
}
