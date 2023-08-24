import 'dart:convert';

String? tryBase64Decode(value) {
  try {
    return utf8.decode(base64Decode(value));
  } catch (e) {
    return null;
  }
}
