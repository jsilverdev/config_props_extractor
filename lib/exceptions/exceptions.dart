// coverage:ignore-file
abstract class AppException implements Exception {
  final String _message;

  const AppException(this._message);

  @override
  String toString() => _message;
}

class ExecutableNotFoundInPathException extends AppException {
  const ExecutableNotFoundInPathException(
    final String executable,
  ) : super("$executable is not found in the PATH. Check is it installed or in the PATH");
}

class ConfigPropertyMissingException extends AppException {
  const ConfigPropertyMissingException({
    required final String property,
  }) : super('The config property "$property" is not defined');
}

abstract class YamlException extends AppException {
  YamlException(super._message);
}

class YamlMissingKeyException extends YamlException {
  YamlMissingKeyException({
    required String key,
    required String path,
  }) : super('Missing "$key" key in the yaml file located at: $path');
}

class YamlKeyValueMissingException extends YamlException {
  YamlKeyValueMissingException({
    required String key,
    required value,
    required String path,
  }) : super('The "$key" key doest no have the value "$value" in the yaml file located at: $path');
}
