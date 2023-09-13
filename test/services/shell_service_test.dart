import 'dart:io';

import 'package:config_props_extractor/exceptions/file_system_exceptions.dart';
import 'package:config_props_extractor/services/shell_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:process_run/process_run.dart';
import 'package:test/test.dart';

class MockShell extends Mock implements Shell {}

void main() {
  late ShellService shellService;
  late MockShell mockShell;

  setUp(() {
    mockShell = MockShell();
    shellService = ShellService(shell: mockShell);
  });

  group('Which', () {
    late ShellOptions shellOptions;
    late ShellEnvironment environment;

    setUp(() {
      environment = ShellEnvironment.empty()..paths.clear();
      shellOptions = ShellOptions(
        environment: environment,
        includeParentEnvironment: false,
      );
    });

    test(
      'Should find executable in PATH',
      () async {
        // arrange
        environment.paths.addAll(["test/_data/executables"]);
        when(() => mockShell.options).thenReturn(shellOptions);

        expect(
          // act
          () => shellService.checkExecutable("example"),
          // assert
          returnsNormally,
        );
      },
    );

    test(
      'Should throws if executable is not in PATH',
      () async {
        // arrange
        when(() => mockShell.options).thenReturn(shellOptions);

        expect(
          // act
          () => shellService.checkExecutable("example"),
          // assert
          throwsA(isA<ExecutableNotFoundInPathException>()),
        );
      },
    );

    test(
      'Should throws if executable basename is not equal at executable',
      () async {
        // arrange
        when(() => mockShell.options).thenReturn(shellOptions);

        expect(
          // act
          () => shellService.checkExecutable("/path/to/example"),
          // assert
          throwsA(
            isA<ExecutableNotFoundInPathException>(),
          ),
        );
      },
    );
  });

  group('Run Shell', () {
    test(
      'Should Run Script',
      () async {
        // arrange
        List<ProcessResult> expectedResult = [];
        when(
          () => mockShell.run(any()),
        ).thenAnswer(
          (_) async => expectedResult,
        );

        // act
        final result = await shellService.runScript("example");

        // assert
        expect(result, equals(expectedResult));
      },
    );

    test(
      'Should move the shell to the selected folder',
      () async {
        // arrange
        final folderPath = "/path/to/anotherFolder";

        when(
          () => mockShell.pushd(any()),
        ).thenReturn(Shell(workingDirectory: folderPath));

        // act
        shellService.moveShellTo(folderPath);
        // assert
        expect(
          shellService.workingDir,
          equals(folderPath),
        );
      },
    );

    test(
      'Should move the shell to back',
      () async {
        // arrange
        final folderPath = "/path/to";
        when(
          () => mockShell.popd(),
        ).thenReturn(Shell(workingDirectory: folderPath));
        // act
        shellService.popShell();
        // assert
        expect(
          shellService.workingDir,
          equals(folderPath),
        );
      },
    );

    test(
      'Should Dispose All Correctly',
      () async {
        // arrange
        when(() => mockShell.kill()).thenReturn(true);
        expect(
          // act
          () => shellService.dispose(),
          // assert
          returnsNormally,
        );
      },
    );
  });
}
