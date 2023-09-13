import 'package:config_props_extractor/utils/git_utils.dart';
import 'package:test/test.dart';

void main() {
  test(
    'Should check if current url is git url',
    () async {
      // arrange
      final validUrls = [
        "https://fake.git/test/url/repo.git",
        "http://fake.git/test/url/repo.git",
        "git@fake.git:test/url/repo.git",
        "git@gitlab.com:test/url/repo.git",
        "test@fake.git:test/url/repo.git",
      ];

      final invalidUrls = [
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
      final urls = [
        "https://fake.git/test/url/repo.git",
        "http://fake.git/test/url/repo.git",
        "git@fake.git:test/url/repo.git",
        "git@gitlab.com:test/url/repo.git",
        "test@fake.git:test/url/repo.git",
      ];

      // act
      for (var url in urls) {
        // assert
        expect(extractGitPath(url), "test/url/repo");
      }

    },
  );
}
