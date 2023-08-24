extension ToBooleanExtension on String {
  bool toBoolean() {
    return bool.tryParse(this, caseSensitive: false) ?? false;
  }
}
