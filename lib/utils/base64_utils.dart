import 'dart:convert';

String? tryBase64Decode(
  dynamic value, {
  Function? onFailed,
}) {
  try {
    return utf8.decode(base64Decode(value));
  } catch (e) {
    onFailed?.call();
    return null;
  }
}
