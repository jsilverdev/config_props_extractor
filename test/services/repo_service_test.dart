import 'dart:async';
import 'dart:io';

import 'package:config_props_extractor/constants/constants.dart';
import 'package:config_props_extractor/exceptions/exceptions.dart';
import 'package:config_props_extractor/exceptions/file_system_exceptions.dart';
import 'package:config_props_extractor/exceptions/git_exceptions.dart';
import 'package:config_props_extractor/models/git_repo.dart';
import 'package:config_props_extractor/services/repo_service.dart';
import 'package:config_props_extractor/utils/string_utils.dart';
import 'package:fake_async/fake_async.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as path;
import 'package:process_run/process_run.dart';
import 'package:test/test.dart';

import '../helpers/git_helper.dart';
import '../helpers/mocks.dart';

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
      reposFolder: reposFolder,
    );
  });

  group('Load Pre-requisites', () {
    test(
      'Should load pre-requisites for git path',
      () async {
        // arrange
        when(() => mockAppConfig.gitRepoPath).thenReturn(gitPath);
        when(() => mockAppConfig.gitBranch).thenReturn(gitBranch);
        // act
        final gitRepo = repoService.preRequisites();
        // assert
        expect(gitRepo, isNotNull);
        expect(path.equals(gitRepo.gitDir.path, gitPath), equals(true));
        expect(gitRepo.gitUrl, "");
        expect(gitRepo.branch, gitBranch);
        expect(gitRepo.toClone, false);
      },
    );

    test(
      'Should load pre-requisites for git url',
      () async {
        // arrange
        when(() => mockAppConfig.gitRepoPath).thenReturn(gitUrl);
        when(() => mockAppConfig.gitBranch).thenReturn(gitBranch);
        // act
        final gitRepo = repoService.preRequisites();
        // assert
        expect(gitRepo, isNotNull);
        expect(path.equals(gitRepo.gitDir.path, gitPath), equals(true));
        expect(gitRepo.gitUrl, gitUrl);
        expect(gitRepo.branch, gitBranch);
        expect(gitRepo.toClone, true);
      },
    );
  });

  group('Try Cloning', () {
    late GitRepo gitRepo;
    final gitDirToClone = Directory("test/_data/folder_to_clone");

    setUp(() {
      gitRepo = generateGitRepo(
        gitPath: gitDirToClone.path,
        toClone: true,
      );
    });

    tearDown(() {
      if (gitDirToClone.existsSync()) {
        gitDirToClone.deleteSync(recursive: true);
      }
    });

    test(
      'Should Stop if is not remote',
      () async {
        // arrange
        final localGitRepo = GitRepo(
          gitPath: gitPath,
          gitUrl: "",
          branch: gitBranch,
          toClone: false,
        );
        // act
        await repoService.tryCloning(localGitRepo);
        // assert
        verifyNever(
          () => mockShellService.runScript(
            any(that: contains("git")),
          ),
        );
      },
    );

    test(
      'Should Delete Git Dir if Has not commits and then clone successfully',
      () async {
        // arrange
        gitDirToClone.createSync();
        when(
          () => mockShellService.runScript(any(that: contains("git"))),
        ).thenAnswer(
          (_) async => [],
        );
        when(
          () => mockShellService.runScript(GIT_REV_PARSE_HEAD),
        ).thenAnswer(
          (_) async => throw AppShellException(ShellException("message", null)),
        );
        when(() => mockAppConfig.gitSSLEnabled).thenReturn(false);
        when(() => mockAppConfig.maxDuration).thenReturn(Duration.zero);
        // act
        await repoService.tryCloning(gitRepo);
        // assert
        expect(gitRepo.wasCloned, equals(true));
        verify(() => mockShellService.runScript(GIT_REV_PARSE_HEAD));
        verify(
          () => mockShellService.runScript(GIT_CLONE.format([
            gitRepo.gitUrl,
            gitRepo.gitDir.absolute.path,
            "-c $GIT_SSL_VERIFY_FALSE",
          ])),
        );
        verifyInOrder([
          () => mockShellService.moveShellTo(gitRepo.gitDir.absolute.path),
          () => mockShellService.popShell()
        ]);
      },
    );

    test(
      'Should stop if path exists and has commits',
      () async {
        // arrange
        gitDirToClone.createSync();
        when(
          () => mockShellService.runScript(
            GIT_REV_PARSE_HEAD,
          ),
        ).thenAnswer((_) async => []);

        // act
        await repoService.tryCloning(gitRepo);

        // assert
        expect(gitRepo.existsOnLocal, equals(true));
        verify(
          () => mockShellService.runScript(
            GIT_REV_PARSE_HEAD,
          ),
        );
        verifyNever(
          () => mockShellService.runScript(any(
            that: contains("git"),
          )),
        );
        verifyInOrder([
          () => mockShellService.moveShellTo(gitRepo.gitDir.absolute.path),
          () => mockShellService.popShell()
        ]);
      },
    );
  });

  group("Check Git Path", () {
    test(
      'Should throws FolderNotFoundException if path no exits',
      () async {
        // arrange
        final gitRepo = generateGitRepo(
          gitPath: "test/_data/no_found_folder",
        );

        expect(
          // act
          () async => repoService.checkGitPath(gitRepo),
          // assert
          throwsA(isA<FolderNotFoundException>()),
        );
      },
    );

    test(
      'Should throws IncorrectTopLevelGitPathException if path is not the top git repo',
      () async {
        // arrange
        final gitRepo = generateGitRepo();
        when(
          () => mockShellService.runScript(
            any(that: contains("git")),
          ),
        ).thenAnswer(
          (_) async => [
            ProcessResult(pid, exitCode, "/another/path", stderr),
          ],
        );

        expect(
          // act
          () => repoService.checkGitPath(gitRepo),
          // assert
          throwsA(isA<IncorrectTopLevelGitPathException>()),
        );
        verify(() => mockShellService.runScript(GIT_TOP_LEVEL_PATH));
      },
    );
  });

  group('Try Fetching Changes', () {
    test(
      'Should Stop if force remote is disabled and is not from remote',
      () async {
        // arrange
        when(() => mockAppConfig.gitForceRemote).thenReturn(false);
        final gitRepo = generateGitRepo();
        // act
        repoService.tryFetchingChanges(gitRepo);
        // assert
        verifyNever(
          () => mockShellService.runScript(
            any(that: contains("git")),
          ),
        );
      },
    );

    test(
      'Should assign current branch if is not defined',
      () async {
        // arrange
        final gitRepo = generateGitRepo(branch: "");
        when(() => mockAppConfig.gitForceRemote).thenReturn(false);
        when(
          () => mockShellService.runScript(GIT_BRANCH_SHOW_CURRENT),
        ).thenAnswer(
          (_) async => [
            ProcessResult(pid, exitCode, gitBranch, stderr),
          ],
        );
        // act
        await repoService.tryFetchingChanges(gitRepo);
        // assert
        expect(gitRepo.branch, gitBranch);
      },
    );

    test(
      'Should fetch successfully if force remote is enabled',
      () async {
        // arrange
        final gitRepo = generateGitRepo(toClone: false);
        when(() => mockAppConfig.gitSSLEnabled).thenReturn(true);
        when(() => mockAppConfig.gitForceRemote).thenReturn(true);
        when(() => mockAppConfig.maxDuration).thenReturn(Duration.zero);
        when(() => mockShellService.runScript(any(that: contains("git"))))
            .thenAnswer((_) async => []);
        // act
        await repoService.tryFetchingChanges(gitRepo);
        // assert
        verify(
          () => mockShellService.runScript(
            GIT_REFRESH_BRANCH.format([gitBranch, ""]),
          ),
        );
      },
    );

    test(
      "Should fetch successfully if it is set to clone but wasn't cloned",
      () async {
        // arrange
        final gitRepo = generateGitRepo(toClone: true);
        when(() => mockAppConfig.gitSSLEnabled).thenReturn(true);
        when(() => mockAppConfig.gitForceRemote).thenReturn(false);
        when(() => mockAppConfig.maxDuration).thenReturn(Duration.zero);
        when(() => mockShellService.runScript(any(that: contains("git"))))
            .thenAnswer((_) async => []);
        // act
        await repoService.tryFetchingChanges(gitRepo);
        // assert
        verify(
          () => mockShellService.runScript(
            GIT_REFRESH_BRANCH.format([gitBranch, ""]),
          ),
        );
      },
    );

    test(
      'Should throws a timeout Exception if taking many time',
      () async {
        // arrange
        final gitRepo = generateGitRepo();
        when(() => mockAppConfig.gitSSLEnabled).thenReturn(true);
        when(() => mockAppConfig.gitForceRemote).thenReturn(true);
        when(() => mockAppConfig.maxDuration).thenReturn(Duration(minutes: 2));
        when(() => mockShellService.runScript(
              GIT_REFRESH_BRANCH.format([
                gitBranch,
                "",
              ]),
            )).thenAnswer((_) async {
          await Completer().future.timeout(Duration(minutes: 3));
          return [];
        });

        FakeAsync().run((self) {
          expect(
            // act
            () => repoService.tryFetchingChanges(gitRepo),
            // assert
            throwsA(isA<GitRemoteToManyTimeException>()),
          );
          self.elapse(Duration(minutes: 3));
        });
      },
    );
  });

  group('Apply Changes', () {
    test(
      'Should Apply Changes Successfully',
      () async {
        // arrange
        final gitRepo = generateGitRepo();
        when(
          () => mockShellService.runScript(
            any(that: contains("git")),
          ),
        ).thenAnswer((_) async => []);
        // act
        await repoService.applyChanges(gitRepo);
        // assert
        verify(
          () => mockShellService.runScript(
            GIT_CHECKOUT.format([
              gitRepo.branch,
            ]),
          ),
        );
        verify(() => mockShellService.runScript(
              GIT_OVERRIDE_WITH_REMOTE.format([
                gitRepo.branch,
              ]),
            ));
      },
    );
  });
}
