import 'dart:io';

class GitRepo {
  final Directory gitDir;
  final String gitUrl;
  String branch;
  final bool toClone;
  bool wasCloned = false;

  GitRepo({
    required String gitPath,
    required this.gitUrl,
    required this.branch,
    required this.toClone,
  }) : gitDir = Directory(gitPath).absolute;

  bool get existsOnLocal => gitDir.existsSync();
}
