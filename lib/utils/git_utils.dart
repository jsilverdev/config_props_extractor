final _validUrlRegex = RegExp(
  r"^(([A-Za-z0-9]+@|http(|s)\:\/\/)|(http(|s)\:\/\/[A-Za-z0-9]+@))([A-Za-z0-9.]+(:\d+)?)(?::|\/)([\d\/\w-]+?)(\.git){0,1}(/?)$",
  caseSensitive: false,
  multiLine: false,
);

bool isValidGitUrl(String url) {
  return _validUrlRegex.hasMatch(url);
}

String extractPathFromGitUrl(String url) {
  if (url.endsWith(".git")) {
    url = url.substring(0, url.length - 4);
  }

  // Remove "http://" or "https://"
  url = url.replaceFirst(RegExp(r"https?:\/\/"), "");
  // Remove any@
  url = url.replaceFirst(RegExp(r"^[^@]+@"), "");
  // Remove invalid windows caracteres
  return url.replaceAll(RegExp(r'[\\/:*?"<>|]'), "/");
}
