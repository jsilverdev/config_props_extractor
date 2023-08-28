import 'dart:io';

import 'package:logger/logger.dart';

final logger = Logger(
  level: Level.all,
  filter: ProductionFilter(),
  printer: PrettyPrinter(
    methodCount: 0,
    excludeBox: {
      Level.trace: true
    },
    colors: stdout.supportsAnsiEscapes,
    lineLength: stdout.terminalColumns,
  ),
);
