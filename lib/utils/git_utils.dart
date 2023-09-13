bool isValidGitUrl(String url) {
  final regExp = RegExp(
    "((http|git|ssh|http(s)|file|\\/?)|(git@[\\w\\.]+))(:(\\/\\/)?)([\\w\\.@\\:/\\-~]+)(\\.git)(\\/)?",
    caseSensitive: false,
    multiLine: false,
  );
  return regExp.hasMatch(url);
}

String extractGitPath(String url) {
  if (url.endsWith(".git")) {
    url = url.substring(0, url.length - 4);
  }
  RegExp httpRegex = RegExp(r"https?://[^/]+/");
  url = url.replaceFirst(httpRegex, "");

  RegExp sshRegex = RegExp(r"^([^@]+@[^:/]+:)");
  url = url.replaceFirst(sshRegex, "");
  return url;
}
