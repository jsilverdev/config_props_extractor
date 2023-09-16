import 'dart:async';
import 'dart:io';

import 'package:config_props_extractor/constants/constants.dart';
import 'package:config_props_extractor/exceptions/config_exceptions.dart';
import 'package:config_props_extractor/exceptions/file_system_exceptions.dart';
import 'package:config_props_extractor/exceptions/git_exceptions.dart';
import 'package:config_props_extractor/services/repo_service.dart';
import 'package:config_props_extractor/utils/string_utils.dart';
import 'package:fake_async/fake_async.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart';
import 'package:process_run/process_run.dart';
import 'package:test/test.dart';

import '../helpers/mocks.dart';
import '../helpers/process_run_helper.dart';

void main() {
  late MockAppConfig mockAppConfig;
  late MockShellService mockShellService;
  late RepoService repoService;

  setUp(() {
    mockAppConfig = MockAppConfig();
    mockShellService = MockShellService();

    repoService = RepoService(mockAppConfig, mockShellService,
        defaultParentFolder: "test/_data");
    when(() => mockAppConfig.maxDuration).thenReturn(Duration(minutes: 2));
  });

  group('Setup', () {
    setUp(() {
      when(() => mockAppConfig.gitSSLEnabled).thenReturn(true);
    });

    const branch = "selected_branch";
    const gitDirPath = "test/_data/test.test/configs/config";
    const gitUrlPath = "https://test.test/configs/config.git";
    final gitAbsoluteDirPath =
        absolute("test/_data", 'test.test/configs/config');

    void createFolder(path) {
      final dir = Directory(path);
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
    }

    void destroyFolder(path) {
      final dir = Directory(path);
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
    }

    tearDown(() {
      destroyFolder(gitAbsoluteDirPath);
    });

    Future<void> testSetup({
      required bool isBranchDefined,
      required bool gitForceRemote,
      String gitConfig = "",
      String path = gitDirPath,
      Map<String, List<ProcessResult> Function()> scriptsInOrder = const {},
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
        when(() => mockShellService.runScript(script)).thenAnswer(
          (_) async => results(),
        );
      });

      // act
      await repoService.setup();

      // assert

      verify(
        () => mockShellService.moveShellTo(
          path == gitDirPath ? path : gitAbsoluteDirPath,
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
      () async {
        createFolder(gitAbsoluteDirPath);
        await testSetup(
          isBranchDefined: true,
          gitForceRemote: true,
          scriptsInOrder: {
            GIT_TOP_LEVEL_PATH: () => [processResult(stdout: gitDirPath)],
            GIT_REFRESH_BRANCH.format([branch, ""]): () => [],
            GIT_CHECKOUT.format([branch]): () => [],
            GIT_OVERRIDE_WITH_REMOTE.format([branch]): () => []
          },
        );
      },
    );

    test(
      'Should run success when repo is folder and git SLL is disabled',
      () async {
        createFolder(gitAbsoluteDirPath);
        when(() => mockAppConfig.gitSSLEnabled).thenReturn(false);
        await testSetup(
          isBranchDefined: true,
          gitForceRemote: true,
          gitConfig: "-c $GIT_SSL_VERIFY_FALSE",
          scriptsInOrder: {
            GIT_TOP_LEVEL_PATH: () => [processResult(stdout: gitDirPath)],
            GIT_REFRESH_BRANCH.format([
              branch,
              "-c $GIT_SSL_VERIFY_FALSE",
            ]): () => [],
            GIT_CHECKOUT.format([branch]): () => [],
            GIT_OVERRIDE_WITH_REMOTE.format([branch]): () => []
          },
        );
      },
    );

    test('Should run success when repo is folder and force remote is false',
        () async {
      createFolder(gitAbsoluteDirPath);
      await testSetup(
        isBranchDefined: false,
        gitForceRemote: false,
        scriptsInOrder: {
          GIT_TOP_LEVEL_PATH: () => [processResult(stdout: gitAbsoluteDirPath)],
          GIT_BRANCH_SHOW_CURRENT: () => [processResult(stdout: branch)],
          GIT_CHECKOUT.format([branch]): () => [],
        },
      );
    });

    test(
      'Should run success when gitRepoPath is Url and gitPath not exits',
      () async {
        testSetup(
            isBranchDefined: true,
            gitForceRemote: false,
            path: gitUrlPath,
            scriptsInOrder: {
              GIT_CLONE.format([gitUrlPath, gitAbsoluteDirPath, ""]): () {
                createFolder(gitAbsoluteDirPath);
                return [];
              },
              GIT_TOP_LEVEL_PATH: () =>
                  [processResult(stdout: gitAbsoluteDirPath)],
              GIT_CHECKOUT.format([branch]): () => [],
            });
      },
    );

    test(
      'Should run success when gitRepoPath is Url and gitPath exists',
      () async {
        createFolder(gitAbsoluteDirPath);
        testSetup(
            isBranchDefined: true,
            gitForceRemote: false,
            path: gitUrlPath,
            scriptsInOrder: {
              GIT_TOP_LEVEL_PATH: () =>
                  [processResult(stdout: gitAbsoluteDirPath)],
              GIT_CHECKOUT.format([branch]): () => [],
            });
      },
    );

    test(
      'Should fail when git clone fail',
      () async {
        // arrange
        when(() => mockAppConfig.gitRepoPath).thenReturn(gitUrlPath);
        when(() => mockAppConfig.gitForceRemote).thenReturn(false);
        when(() => mockShellService.runScript(GIT_CLONE.format([
              gitUrlPath,
              gitAbsoluteDirPath,
              "",
            ]))).thenAnswer((_) async => throw ShellException("message", null));
        expect(
          // act
          () => repoService.setup(),
          // assert
          throwsA(isA<GitShellException>()),
        );
      },
    );

    test(
      'Should fail if Local Branch not exists',
      () async {
        createFolder(gitAbsoluteDirPath);
        // arrange
        when(() => mockAppConfig.gitRepoPath).thenReturn(gitDirPath);
        when(() => mockAppConfig.gitForceRemote).thenReturn(false);
        when(() => mockShellService.runScript(GIT_TOP_LEVEL_PATH)).thenAnswer(
          (_) async => [processResult(stdout: gitDirPath)],
        );
        when(() => mockAppConfig.gitBranch).thenReturn("fail_branch");
        when(() => mockShellService
                .runScript(GIT_CHECKOUT.format(["fail_branch"])))
            .thenAnswer((_) async => throw ShellException("exception", null));
        expect(
          // act
          () => repoService.setup(),
          // assert
          throwsA(isA<GitShellException>()),
        );
      },
    );

    test(
      'Should fail if Remote Branch not exists',
      () async {
        createFolder(gitAbsoluteDirPath);
        // arrange
        when(() => mockAppConfig.gitRepoPath).thenReturn(gitDirPath);
        when(() => mockAppConfig.gitForceRemote).thenReturn(true);
        when(() => mockShellService.runScript(GIT_TOP_LEVEL_PATH)).thenAnswer(
          (_) async => [processResult(stdout: gitDirPath)],
        );
        when(() => mockAppConfig.gitBranch).thenReturn("fail_branch");
        when(() => mockShellService
                .runScript(GIT_REFRESH_BRANCH.format(["fail_branch", ""])))
            .thenAnswer((_) async => throw ShellException("exception", null));
        // act
        expect(
          // act
          () => repoService.setup(),
          // assert
          throwsA(isA<GitShellException>()),
        );
      },
    );

    test(
      'Should fail if git refresh branch is taking too much',
      () async {
        createFolder(gitAbsoluteDirPath);
        // arrange
        when(() => mockAppConfig.gitRepoPath).thenReturn(gitDirPath);
        when(() => mockAppConfig.gitForceRemote).thenReturn(true);
        when(() => mockAppConfig.maxDuration).thenReturn(Duration(minutes: 1));
        when(() => mockShellService.runScript(GIT_TOP_LEVEL_PATH)).thenAnswer(
          (_) async => [processResult(stdout: gitDirPath)],
        );
        when(() => mockAppConfig.gitBranch).thenReturn("fail_branch");
        when(() => mockShellService
                .runScript(GIT_REFRESH_BRANCH.format(["fail_branch", ""])))
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
      createFolder(gitAbsoluteDirPath);
      when(() => mockAppConfig.gitRepoPath).thenReturn(gitDirPath);
      when(() => mockShellService.runScript(GIT_TOP_LEVEL_PATH)).thenAnswer(
        (_) async => [ProcessResult(pid, exitCode, "/another/path", stderr)],
      );

      expect(
        // act
        () => repoService.setup(),
        // assert
        throwsA(isA<IncorrectTopLevelGitPathException>()),
      );
    });

    test("The folder not exists", () {
      // arrange
      when(() => mockAppConfig.gitRepoPath).thenReturn(gitDirPath);

      expect(
        // act
        () => repoService.setup(),
        // assert
        throwsA(isA<FolderNotFoundException>()),
      );
    });

    test("The path is not in the top-level of the git repository", () {
      // arrange
      createFolder(gitAbsoluteDirPath);
      when(() => mockAppConfig.gitRepoPath).thenReturn(gitDirPath);
      when(() => mockShellService.runScript(GIT_TOP_LEVEL_PATH))
          .thenAnswer((_) async => throw ShellException("exception", null));

      expect(
        // act
        () => repoService.setup(),
        // assert
        throwsA(isA<GitShellException>()),
      );
    });
  });
}
