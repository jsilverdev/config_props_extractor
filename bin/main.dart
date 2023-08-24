import 'package:config_props_extractor/config/app_config.dart';
import 'package:config_props_extractor/exceptions/handler/handler.dart';
import 'package:config_props_extractor/services/transform_service.dart';
import 'package:config_props_extractor/services/repo_service.dart';
import 'package:config_props_extractor/services/shell_service.dart';

void main(List<String> arguments) {
  Handler().handle(() => runApp(arguments));
}

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
