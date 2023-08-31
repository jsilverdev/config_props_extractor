import 'dart:io';

import 'package:config_props_extractor/constants/constants.dart';
import 'package:config_props_extractor/exceptions/exceptions.dart';
import 'package:config_props_extractor/services/repo_service.dart';
import 'package:config_props_extractor/services/shell_service.dart';
import 'package:config_props_extractor/utils/string_utils.dart';
import 'package:mocktail/mocktail.dart';
import 'package:process_run/process_run.dart';
import 'package:test/test.dart';

import '../helpers/mocks.dart';

class MockShellService extends Mock implements ShellService {}

void main() {
  late MockAppConfig mockAppConfig;
  late MockShellService mockShellService;
  late RepoService repoService;

  setUp(() {
    mockAppConfig = MockAppConfig();
    mockShellService = MockShellService();

    repoService = RepoService(
      mockAppConfig,
      mockShellService,
    );
  });

  group('Setup', () {
    Future<void> testSetup({
      required bool isBranchDefined,
      required bool gitForceRemote,
      required int runScriptTimes,
    }) async {
      // arrange
      final path = "/path/to/folder";
      final branch = "selected_branch";
      bool firstExec = true;

      when(() => mockAppConfig.gitRepoPath).thenReturn(path);
      when(() => mockAppConfig.gitBranch).thenAnswer(
        (_) {
          if (isBranchDefined) return branch;
          if (firstExec) {
            firstExec = false;
            return '';
          }
          return branch;
        },
      );
      when(() => mockAppConfig.gitForceRemote).thenReturn(gitForceRemote);
      when(() => mockAppConfig.gitSSLEnabled).thenReturn(true);
      when(() => mockShellService.runScript(GIT_BRANCH_SHOW_CURRENT)).thenAnswer(
        (_) async => [ProcessResult(pid, exitCode, branch, stderr)],
      );
      when(() => mockShellService.runScript(GIT_CHECKOUT.format([branch]))).thenAnswer(
        (_) async => [],
      );
      when(() => mockShellService.runScript(GIT_REMOTE_HARD_RESET.format([branch, ""]))).thenAnswer(
        (_) async => [],
      );
      when(() => mockShellService.runScript(GIT_TOP_LEVEL_PATH)).thenAnswer(
        (_) async => [ProcessResult(pid, exitCode, path, stderr)],
      );

      // act
      await repoService.setup();

      // assert
      verify(() => mockShellService.moveShellTo(path));
      verify(() => mockShellService.checkExecutable(GIT));
      verify(() => mockShellService.runScript(any(that: contains(GIT)))).called(
        runScriptTimes,
      );
    }

    test(
      'Should run 1 time a git script when branch is defined, git force from remote and SSL is enabled',
      () async => await testSetup(
        isBranchDefined: true,
        gitForceRemote: true,
        runScriptTimes: 2,
      ),
    );

    test(
      'Should run 1 time a git script when branch is defined, git force from remote is enabled and SSL is disabled',
      () async => testSetup(
        isBranchDefined: true,
        gitForceRemote: true,
        runScriptTimes: 2,
      ),
    );

    test(
      'Should run 2 times a git script when branch is not defined, git force from remote is disabled',
      () async => testSetup(
        isBranchDefined: false,
        gitForceRemote: false,
        runScriptTimes: 3,
      ),
    );

    test(
      "Can't find gitRepoPath",
      () async {
        // arrange
        when(() => mockAppConfig.gitRepoPath).thenThrow(
          ConfigPropertyMissingException(property: 'missingProp'),
        );

        expect(
          // act
          () => repoService.setup(),
          // assert
          throwsA(isA<ConfigPropertyMissingException>()),
        );
      },
    );

    test("Can't find executable", () {
      // arrange
      when(() => mockAppConfig.gitRepoPath).thenReturn("/path/to/folder");
      when(() => mockShellService.checkExecutable(any())).thenThrow(
        ExecutableNotFoundInPathException(GIT),
      );

      expect(
        // act
        () => repoService.setup(),
        // assert
        throwsA(isA<ExecutableNotFoundInPathException>()),
      );
    });


    test("The path is invalid git repository", () {
      // arrange
      when(() => mockAppConfig.gitRepoPath).thenReturn("/path/to/sub/folder");
      when(() => mockShellService.runScript(GIT_TOP_LEVEL_PATH)).thenAnswer(
        (_) async => [ProcessResult(pid, exitCode, "/path/to/sub", stderr)],
      );

      expect(
        // act
        () => repoService.setup(),
        // assert
        throwsA(isA<IncorrectTopLevelGitPathException>()),
      );
    });

    test("The path is not in the top-level of the git repository", () {
      // arrange
      when(() => mockAppConfig.gitRepoPath).thenReturn("/path/to/folder");
      when(() => mockShellService.runScript(GIT_TOP_LEVEL_PATH))
      .thenAnswer((_) async => throw ShellException("exception", null));

      expect(
        // act
        () => repoService.setup(),
        // assert
        throwsA(isA<InvalidValidGitPathException>()),
      );
    });
  });

  test(
    'Should Dispose Correctly',
    () async {
      // arrange
      when(() => mockShellService.dispose()).thenReturn(
        null,
      );

      expect(
        // act
        () => repoService.dispose(),
        // assert
        returnsNormally,
      );
    },
  );
}
