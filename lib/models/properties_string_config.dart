class PropertiesStringConfig {
  final String breakLine;
  final String entrySeparator;
  final String keyValueSeparator;
  final String? valueNotDefined;

  PropertiesStringConfig.custom({
    this.breakLine = defaultBreakLine,
    required this.entrySeparator,
    required this.keyValueSeparator,
    this.valueNotDefined,
  });

  PropertiesStringConfig.properties()
      : breakLine = " \\\n",
        entrySeparator = "\n",
        keyValueSeparator = "=",
        valueNotDefined = "";

  PropertiesStringConfig.txt()
      : breakLine = "",
        entrySeparator = ";",
        keyValueSeparator = "=",
        valueNotDefined = "";

  static const String defaultBreakLine = "\n";
}
