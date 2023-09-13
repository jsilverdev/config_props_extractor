import 'package:config_props_extractor/exceptions/exceptions.dart';
import 'package:config_props_extractor/exceptions/git_exceptions.dart';
import 'package:config_props_extractor/exceptions/handler/handler.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockAppException extends Mock implements AppException {}

class MockGitException extends Mock implements GitException {}

void main() {
  test('Run Correctly', () async {
    expect(
      () => handle(() => {}),
      returnsNormally,
    );
  });


  test('Catch GitException', () async {
    expect(
      () => handle(() {
        throw MockGitException();
      }),
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
