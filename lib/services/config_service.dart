import 'package:dotenv/dotenv.dart';

class ConfigService {
  late DotEnv _dotEnv;

  ConfigService({DotEnv? env}) {
    _dotEnv = env ?? (DotEnv(includePlatformEnvironment: true)..load());
  }
}