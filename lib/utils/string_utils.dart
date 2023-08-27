extension StringExtension on String {
  bool toBoolean() {
    return bool.tryParse(this, caseSensitive: false) ?? false;
  }

  String format(List<String> params) => _interpolate(this, params);

  String _interpolate(String string, List<String> params) {
    String result = string;
    final isSimple = result.contains('{}');
    for (int i = 1; i < params.length + 1; i++) {
      final param = params[i - 1];
      result = isSimple
          ? result.replaceFirst('{}', param)
          : result.replaceAll('{$i}', param);
    }
    return result;
  }
}
