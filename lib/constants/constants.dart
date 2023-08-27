// ignore_for_file: constant_identifier_names
const String DEFAULT_CONFIG_MAP_PATH = "configMap";

const String DEFAULT_CONFIG_SECRET_PATH = "secret";

const String GIT = "git";

const String GIT_BRANCH_SHOW_CURRENT = "git branch --show-current";

const String GIT_CHECKOUT = "git checkout {}";

const String GIT_REMOTE_HARD_RESET = '''
  git checkout {1}
  git {2} fetch origin {1}
  git reset --hard origin/{1}
''';

const GIT_SSL_VERIFY_FALSE = "http.sslVerify=false";