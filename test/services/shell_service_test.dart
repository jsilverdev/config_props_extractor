import 'dart:io';

import 'package:config_props_extractor/exceptions/file_system_exceptions.dart';
import 'package:config_props_extractor/services/shell_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:process_run/process_run.dart';
import 'package:test/test.dart';

class _MockShell extends Mock implements Shell {}

class _MockProcessSignal extends Mock implements ProcessSignal {}

class _MockProcess extends Mock implements Process {}

void main() {
  late ShellService shellService;
  late _MockShell mockShell;

  setUp(() {
    mockShell = _MockShell();
  });

  group('Which', () {
    late ShellOptions shellOptions;
    late ShellEnvironment environment;

    setUp(() {
      shellService = ShellService(shell: mockShell);
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
    setUp(() {
      shellService = ShellService(shell: mockShell);
    });

    test(
      'Should Run Script',
      () async {
        // arrange
        List<ProcessResult> expectedResult = [];
        when(
          () => mockShell.run(any(), onProcess: any(named: 'onProcess')),
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
          shellService.currentPath,
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
          shellService.currentPath,
          equals(folderPath),
        );
      },
    );

    test(
      'Should Dispose Correctly',
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

  group('For Windows', () {
    late _MockProcessSignal mockProcessSignal;
    late _MockProcess mockProcess;

    final processRunCalls = <List<String>>[];

    setUp(() {
      mockProcessSignal = _MockProcessSignal();
      mockProcess = _MockProcess();
      shellService = ShellService(
        shell: mockShell,
        processSignal: mockProcessSignal,
        isWindows: true,
        runProcessSync: (executable, arguments) {
          processRunCalls.add([executable, ...arguments]);
          return ProcessResult(1, 0, "", "");
        },
      );
    });

    test(
      'Should init a script on Windows',
      () async {
        // arrange
        const pid = 100;
        when(() => mockProcess.pid).thenReturn(pid);
        when(() => mockProcessSignal.watch()).thenAnswer(
          (_) => Stream.value(mockProcessSignal),
        );
        when(
          () => mockShell.run(
            any(),
            onProcess: any(named: 'onProcess'),
          ),
        ).thenAnswer((invocation) async {
          (invocation.namedArguments[const Symbol('onProcess')] as Function(
            Process process,
          ))
              .call(mockProcess);

          return List<ProcessResult>.empty();
        });

        // act
        final result = await shellService.runScript("");

        // assert
        expect(result, isNotNull);
        expect(
          processRunCalls,
          equals([
            ['taskkill', '/pid', '$pid', '/f', '/t']
          ]),
        );
        verifyNever(() => mockShell.kill());
      },
    );
  });
}
