import 'dart:async';
import 'dart:io';

import 'package:config_props_extractor/constants/constants.dart';
import 'package:config_props_extractor/exceptions/exceptions.dart';
import 'package:config_props_extractor/services/repo_service.dart';
import 'package:config_props_extractor/services/shell_service.dart';
import 'package:config_props_extractor/utils/string_utils.dart';
import 'package:fake_async/fake_async.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart';
import 'package:process_run/process_run.dart';
import 'package:test/test.dart';

import '../helpers/mocks.dart';
import '../helpers/process_run_helper.dart';

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
    when(() => mockAppConfig.maxDurationInMin).thenReturn(3);
  });

  group('Setup', () {
    setUp(() {
      when(() => mockAppConfig.gitSSLEnabled).thenReturn(true);
    });

    const branch = "selected_branch";
    const gitDirPath = "/path/to/folder";
    const gitUrlPath = "https://testurl.dev/path/to/folder.git";
    final gitUrlAbsoluteDirPath = absolute(REPOS_FOLDER, 'path/to/folder');

    Future<void> testSetup({
      required bool isBranchDefined,
      required bool gitForceRemote,
      String gitConfig = "",
      String path = gitDirPath,
      Map<String, dynamic> scriptsInOrder = const {},
    }) async {
      // arrange
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

      scriptsInOrder.forEach((script, results) {
        when(() => mockShellService.runScript(script)).thenAnswer((_) async {
          if (results is Exception) {
            throw results;
          }
          return results as List<ProcessResult>;
        });
      });

      // act
      await repoService.setup();

      // assert

      verify(
        () => mockShellService.moveShellTo(
          path == gitDirPath ? path : gitUrlAbsoluteDirPath,
        ),
      );
      verify(() => mockShellService.checkExecutable(GIT));
      if (scriptsInOrder.isNotEmpty) {
        verifyInOrder(
          scriptsInOrder.keys
              .map((script) => () => mockShellService.runScript(script))
              .toList(),
        );
      }
    }

    test(
      'Should run success when repo is folder when branch is defined and force remote is enabled',
      () async => testSetup(
        isBranchDefined: true,
        gitForceRemote: true,
        scriptsInOrder: {
          GIT_TOP_LEVEL_PATH: [processResult(stdout: gitDirPath)],
          GIT_REFRESH_BRANCH.format([branch, ""]): List<ProcessResult>.empty(),
          GIT_CHECKOUT.format([branch]): List<ProcessResult>.empty(),
          GIT_OVERRIDE_WITH_REMOTE.format([branch]): List<ProcessResult>.empty()
        },
      ),
    );

    test(
      'Should run success when repo is folder and git SLL is disabled',
      () async {
        when(() => mockAppConfig.gitSSLEnabled).thenReturn(false);
        await testSetup(
          isBranchDefined: true,
          gitForceRemote: true,
          gitConfig: "-c $GIT_SSL_VERIFY_FALSE",
          scriptsInOrder: {
            GIT_TOP_LEVEL_PATH: [processResult(stdout: gitDirPath)],
            GIT_REFRESH_BRANCH.format([branch, "-c $GIT_SSL_VERIFY_FALSE"]):
                List<ProcessResult>.empty(),
            GIT_CHECKOUT.format([branch]): List<ProcessResult>.empty(),
            GIT_OVERRIDE_WITH_REMOTE.format([branch]):
                List<ProcessResult>.empty()
          },
        );
      },
    );

    test(
      'Should run success when repo is folder and force remote is false',
      () async => testSetup(
        isBranchDefined: false,
        gitForceRemote: false,
        scriptsInOrder: {
          GIT_TOP_LEVEL_PATH: [processResult(stdout: gitDirPath)],
          GIT_BRANCH_SHOW_CURRENT: [processResult(stdout: branch)],
          GIT_CHECKOUT.format([branch]): List<ProcessResult>.empty(),
        },
      ),
    );

    test(
      'Should run success when gitRepoPath is Url',
      () async {
        testSetup(
            isBranchDefined: true,
            gitForceRemote: false,
            path: gitUrlPath,
            scriptsInOrder: {
              GIT_CLONE.format([gitUrlPath, gitUrlAbsoluteDirPath, ""]):
                  List<ProcessResult>.empty(),
              GIT_TOP_LEVEL_PATH: [
                processResult(stdout: gitUrlAbsoluteDirPath)
              ],
              GIT_CHECKOUT.format([branch]): List<ProcessResult>.empty(),
            });
      },
    );

    test(
      'Should run success when gitRepoPath is Url and gitPath exists',
      () async {
        testSetup(
            isBranchDefined: true,
            gitForceRemote: false,
            path: gitUrlPath,
            scriptsInOrder: {
              GIT_CLONE.format([gitUrlPath, gitUrlAbsoluteDirPath, ""]):
                  ShellException("message", null),
              GIT_TOP_LEVEL_PATH: [
                processResult(stdout: gitUrlAbsoluteDirPath)
              ],
              GIT_CHECKOUT.format([branch]): List<ProcessResult>.empty(),
            });
      },
    );

    test(
      'Should fail if Local Branch not exists',
      () async {
        // arrange
        when(() => mockAppConfig.gitRepoPath).thenReturn(gitDirPath);
        when(() => mockAppConfig.gitForceRemote).thenReturn(false);
        when(() => mockShellService.runScript(GIT_TOP_LEVEL_PATH)).thenAnswer(
          (_) async => [processResult(stdout: gitDirPath)],
        );
        when(() => mockAppConfig.gitBranch).thenReturn("fail_branch");
        when(() => mockShellService.runScript(GIT_CHECKOUT.format(["fail_branch"])))
        .thenAnswer((_) async => throw ShellException("exception", null));
        // act
        expect(
          // act
          () => repoService.setup(),
          // assert
          throwsA(isA<InvalidGitLocalBranchException>()),
        );
      },
    );

    test(
      'Should fail if Remote Branch not exists',
      () async {
        // arrange
        when(() => mockAppConfig.gitRepoPath).thenReturn(gitDirPath);
        when(() => mockAppConfig.gitForceRemote).thenReturn(true);
        when(() => mockShellService.runScript(GIT_TOP_LEVEL_PATH)).thenAnswer(
          (_) async => [processResult(stdout: gitDirPath)],
        );
        when(() => mockAppConfig.gitBranch).thenReturn("fail_branch");
        when(() => mockShellService.runScript(GIT_REFRESH_BRANCH.format(["fail_branch", ""])))
        .thenAnswer((_) async => throw ShellException("exception", null));
        // act
        expect(
          // act
          () => repoService.setup(),
          // assert
          throwsA(isA<InvalidGitRemoteBranchException>()),
        );
      },
    );

    test(
      'Should fail if git refresh branch is taking too much',
      () async {
        // arrange
        when(() => mockAppConfig.gitRepoPath).thenReturn(gitDirPath);
        when(() => mockAppConfig.gitForceRemote).thenReturn(true);
        when(() => mockAppConfig.maxDurationInMin).thenReturn(1);
        when(() => mockShellService.runScript(GIT_TOP_LEVEL_PATH)).thenAnswer(
          (_) async => [processResult(stdout: gitDirPath)],
        );
        when(() => mockAppConfig.gitBranch).thenReturn("fail_branch");
        when(() => mockShellService.runScript(GIT_REFRESH_BRANCH.format(["fail_branch", ""])))
        .thenAnswer((_) async {
          await Completer().future.timeout(Duration(minutes: 2));
          return [];
        });
        // act

        FakeAsync().run(
          (self) {
            expect(
              // act
              () => repoService.setup(),
              // assert
              throwsA(isA<GitRemoteToManyTimeException>()),
            );
            self.elapse(Duration(minutes: 3));
          },
        );
      },
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
}
