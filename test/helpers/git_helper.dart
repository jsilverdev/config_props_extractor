import 'dart:io';

import 'package:config_props_extractor/models/git_repo.dart';

const reposFolder = "test/_data";
const gitBranch = "selected_branch";
const gitPath = "$reposFolder/test.test/configs";
const gitUrl = "https://test.test/configs";

GitRepo generateGitRepo({
  String gitPath = gitPath,
  String gitUrl = gitUrl,
  String branch = gitBranch,
  bool toClone = false,
}) {
  return GitRepo(
    gitDir: Directory(gitPath),
    gitUrl: gitUrl,
    branch: branch,
    toClone: toClone,
  );
}
