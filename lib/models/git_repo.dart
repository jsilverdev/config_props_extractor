import 'dart:io';

class GitRepo {
  final Directory gitDir;
  final String gitUrl;
  String branch;
  final bool toClone;

  GitRepo({
    required this.gitDir,
    required this.gitUrl,
    required this.branch,
    required this.toClone,
  });
}
