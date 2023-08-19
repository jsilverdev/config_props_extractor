import 'package:config_props_extractor/exceptions/handler/handler.dart';
import 'package:config_props_extractor/services/git_service.dart';
import 'package:config_props_extractor/services/shell_service.dart';
import 'package:process_run/process_run.dart';

String fileArgument = "file";
final shell = Shell();
void main(List<String> arguments) async {
  final shellService = ShellService();
  final gitService = GitService(shellService);

  final filePath = "";
  final branch = "develop";
  // final String configLocation = "";
  // final String secretLocation = "";

  Handler().handle(() async {
    shellService.checkExecutable("git");
    gitService.getLastChangesFromRepo(filePath, branch);
  });
}
