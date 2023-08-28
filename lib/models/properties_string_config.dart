class PropertiesStringConfig {
  final String breakLine;
  final String entrySeparator;
  final String keyValueSeparator;

  PropertiesStringConfig.custom({
    this.breakLine = defaultBreakLine,
    required this.entrySeparator,
    required this.keyValueSeparator
  });

  PropertiesStringConfig.properties()
      : breakLine = " \\\n",
        entrySeparator = "\n",
        keyValueSeparator = "=";

  PropertiesStringConfig.txt()
      : breakLine = "",
        entrySeparator = ";",
        keyValueSeparator = "=";

  static const String defaultBreakLine = "\n";
}
