import 'dart:convert';

import 'package:args/args.dart';
import 'package:properties/properties.dart';
import 'package:string_validator/string_validator.dart' as string_validator;

String fileArgument = "file";
void main(List<String> arguments) {
  final parser = ArgParser()..addOption(fileArgument, abbr: 'f');

  ArgResults argResults = parser.parse(arguments);

  final String filePath = argResults[fileArgument];

  Properties p = Properties.fromFile(filePath);

  for (var key in p.keys) {
    final String value = p.get(key) ?? '';
    if (!string_validator.isBase64(value)) continue;

    final decodedValue = tryBase64Decode(value);
    print("$key=$decodedValue");
  }
}

String tryBase64Decode(value) {
  try {
    return utf8.decode(base64Decode(value));
  } catch (e) {
    // print("Cant decode: $value");
  }
  return value;
}