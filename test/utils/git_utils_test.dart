import 'package:config_props_extractor/utils/git_utils.dart';
import 'package:test/test.dart';

void main() {
  const validUrls = [
    "https://fake.test/test/url/repo.git",
    "http://fake.test/test/url/repo.git",
    "http://fake.test/test/url/repo",
    "git@fake.test:test/url/repo.git",
    "git@fake.test:test/url/repo.git",
    "test@fake.test:test/url/repo.git",
    "test@fake.test:test/url/repo",
  ];

  test(
    'Should check if current url is git url',
    () async {
      // arrange
      final invalidUrls = [
        "http://fake.test/test/url/repo.no_git",
        "test@fake.test:test/url/repo.no_git"
            "path/to/location",
        "",
      ];

      // act
      // assert
      for (var url in validUrls) {
        expect(isValidGitUrl(url), equals(true), reason: "For url $url");
      }
      for (var url in invalidUrls) {
        expect(isValidGitUrl(url), equals(false), reason: "For url $url");
      }
    },
  );

  test(
    'Should extract gitPath',
    () async {
      // arrange
      // act
      for (var url in validUrls) {
        // assert
        expect(
          extractPathFromGitUrl(url),
          "fake.test/test/url/repo",
          reason: "For url $url",
        );
      }
    },
  );
}
