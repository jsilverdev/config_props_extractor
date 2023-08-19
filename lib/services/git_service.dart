import 'shell_service.dart';

class GitService {
  final ShellService _shellService;

  GitService(this._shellService);

  Future<void> getLastChangesFromRepo(String filePath, String branch) async {
    await _shellService.run('''
    # Obtain last version of repo
    cd $filePath
    git checkout $branch
    git fetch origin $branch
    git reset --hard origin/$branch
    ''');
  }
}
