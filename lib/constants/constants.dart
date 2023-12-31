// ignore_for_file: constant_identifier_names
const String DEFAULT_CONFIG_MAP_PATH = "configMap";

const String DEFAULT_CONFIG_SECRET_PATH = "secret";

const String GIT = "git";

const String GIT_BRANCH_SHOW_CURRENT = "git branch --show-current";

const String GIT_CHECKOUT = "git checkout {}";

const String GIT_REFRESH_BRANCH = "git {2} fetch origin {1}";

const String GIT_OVERRIDE_WITH_REMOTE = '''
  git reset --hard origin/{1}
  git clean -dfx
''';

const String GIT_REMOTE_HARD_RESET = '''
  git {2} fetch origin {1}
  git checkout {1}
  git reset --hard origin/{1}
''';

const String GIT_TOP_LEVEL_PATH = "git rev-parse --show-toplevel";

const String GIT_CLONE = "git {3} clone {1} {2}";

const String GIT_REV_PARSE_HEAD = "git rev-parse HEAD";

const GIT_SSL_VERIFY_FALSE = "http.sslVerify=false";

const TXT_FILENAME = "properties_file.txt";

const PROPERTIES_FILENAME = "application-local.properties";

const String REPOS_FOLDER = ".git_repos";
