import 'package:config_props_extractor/exceptions/exceptions.dart';
import 'package:config_props_extractor/exceptions/handler/handler.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockAppException extends Mock implements AppException {}

void main() {
  test('Run Correctly', () async {
    expect(
      () => handle(() => {}),
      returnsNormally,
    );
  });

  test('Catch AppException', () async {
    expect(
      () => handle(() {
        throw MockAppException();
      }),
      returnsNormally,
    );
  });

  test('Catch UnknownException', () async {
    expect(
      () => handle(() {
        throw Exception();
      }),
      returnsNormally,
    );
  });
}
