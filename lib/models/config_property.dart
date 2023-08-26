enum ConfigProperty {
  gitRepoPath("GIT_REPO_PATH"),
  gitForceRemote("GIT_FORCE_REMOTE"),
  gitSSLEnabled("GIT_SSL_ENABLED"),
  gitBranch("GIT_BRANCH"),
  configMapsPath("CONFIG_MAPS_PATH"),
  secretsPath("SECRETS_PATH");

  final String value;
  const ConfigProperty(this.value);
}
