import 'dart:io';

import 'package:config_props_extractor/config/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockStdout extends Mock implements Stdout {}

void main() {
  late MockStdout mockStdout;

  setUp(() {
    mockStdout = MockStdout();
  });

  test('Should Instance logger', () async {
    when(() => mockStdout.hasTerminal).thenReturn(true);
    when(() => mockStdout.supportsAnsiEscapes).thenReturn(true);
    when(() => mockStdout.terminalColumns).thenReturn(100);

    final logger = IOOverrides.runZoned(
      () => log,
      stdout: () => mockStdout,
    );

    expect(logger, isNotNull);
  });
}
