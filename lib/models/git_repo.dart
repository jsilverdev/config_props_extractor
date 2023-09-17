import 'dart:io';

class GitRepo {
  final Directory gitDir;
  final String gitUrl;
  String branch;
  final bool fromRemote;

  GitRepo({
    required this.gitDir,
    required this.gitUrl,
    required this.branch,
    required this.fromRemote,
  });
}
