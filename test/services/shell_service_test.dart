import 'package:config_props_extractor/exceptions/exceptions.dart';
import 'package:config_props_extractor/services/shell_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:process_run/process_run.dart';
import 'package:test/test.dart';

class MockShell extends Mock implements Shell {}

void main() {
  late MockShell mockShell;

  setUp(() {
    mockShell = MockShell();
  });

  group('which', () {
    test(
      'Should find executable in PATH',
      () async {
        // arrange

        ShellEnvironment environment = ShellEnvironment.empty();
        environment.paths.clear();
        environment.paths.addAll(["test/_data/executables"]);

        when(() => mockShell.options).thenReturn(
          ShellOptions(
            environment: environment,
            includeParentEnvironment: false,
          ),
        );

        // act
        final shellService = ShellService(shell: mockShell);
        shellService.checkExecutable("example");
      },
    );

    test(
      'Should throws if executable is not in PATH',
      () async {
        // arrange
        when(() => mockShell.options).thenReturn(
          ShellOptions(
            environment: ShellEnvironment.empty()..paths.clear(),
            includeParentEnvironment: false,
          ),
        );

        final shellService = ShellService(shell: mockShell);

        expect(
          // act
          () => shellService.checkExecutable("test"),
          // assert
          throwsA(isA<ExecutableNotFoundInPathException>()),
        );
      },
    );
  });

  group('shell', () {});
}
