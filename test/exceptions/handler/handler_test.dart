import 'package:config_props_extractor/exceptions/exceptions.dart';
import 'package:config_props_extractor/exceptions/handler/handler.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockAppException extends Mock implements AppException {}

class _MockUnknownException extends Mock implements Exception {}

void main() {
  dynamic fakeExit(int exitCode) {}

  test('Run Correctly', () async {
    expect(
      () => handle(
        () => {},
        exit: fakeExit,
      ),
      returnsNormally,
    );
  });

  test('Catch AppException', () async {
    expect(
      () => handle(
        () {
          throw _MockAppException();
        },
        exit: fakeExit,
      ),
      returnsNormally,
    );
  });

  test('Catch UnknownException', () async {
    expect(
      () => handle(
        () {
          throw _MockUnknownException();
        },
        exit: fakeExit,
      ),
      returnsNormally,
    );
  });
}
