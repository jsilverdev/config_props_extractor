// coverage:ignore-file
import 'exceptions.dart';

abstract class ConfigException extends AppException {
  const ConfigException(super.message);
}

class ConfigPropertyMissingException extends ConfigException {
  const ConfigPropertyMissingException({
    required final String property,
  }) : super('"$property" property is not defined int the .env file');
}