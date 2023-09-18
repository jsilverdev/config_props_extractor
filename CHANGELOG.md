# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog],
and this project adheres to [Semantic Versioning].

## [Unreleased]

- /

## [1.4.2-rc1] - 2023-09-18

### Fixed

- Fixed some tests related to files

## [1.4.1] - 2023-09-18


### Fixed

- Now the urls are only refreshed when are already cloned and not always

## [1.4.0] - 2023-09-17

### Added

- Now always refresh cloned repos
- Improved performance

### Changed

- Updated dependencies

### Fixed

- Sub-Processes now were killed on cancel or on timeout

## [1.3.0] - 2023-09-13

### Added

- Improved validation for git urls, now can accept urls without ".git" for example

### Fixed

- Now can catch all git exceptions and show in terminal
- If the folder doesn't exists stop the process and show a message

## [1.2.0] - 2023-09-12

### Changed

- Now GIT_REPO_PATH variable can accept urls
- This try to clone and if already exists this will use the related folder

### Fixed

-  Now if the some config path not exits, this will be skipped
-  If checkout to an branch that not exists (local or remote), this stop the process and show a message
-  If try to get the latest updates from remote and take many time then stop the process and show a message


## [1.1.0-rc1] - 2023-09-04

### Added

- Test for logger instance


## [1.0.0] - 2023-09-04

### Changed

- Upgraded dependencies


## [1.0.0-rc4] - 2023-08-31

### Added

- Now can validate if the path is a git repository and if is in the top level
- If a value is null his value has empty on .txt and .properties generated files

### Changed

- The null and/or empty values now are added to the generated files

## [1.0.0-rc2] - 2023-08-29

### Fixed

- Fix some tests

## [1.0.0-rc1] - 2023-08-29

- initial release

<!-- Links -->
[keep a changelog]: https://keepachangelog.com/en/1.0.0/
[semantic versioning]: https://semver.org/spec/v2.0.0.html

<!-- Versions -->
[unreleased]: https://github.com/jsilverdev/config_props_extractor/compare/latest...HEAD
[1.4.2-rc1]: https://github.com/jsilverdev/config_props_extractor/compare/7f533699f44b1716f415dcb0160af9a35a880580...v1.4.2-rc1
[1.4.1]: https://github.com/jsilverdev/config_props_extractor/compare/e52eca27d43f9798e275abf8750fdcf6f89d3e1a...v1.4.1
[1.4.0]: https://github.com/jsilverdev/config_props_extractor/compare/bae2b918e2043444dc0f12bd565d534e09621fe3...v1.4.0
[1.3.0]: https://github.com/jsilverdev/config_props_extractor/compare/63af415f9b081af52ff225e805e97820a3f750fd...v1.3.0
[1.2.0]: https://github.com/jsilverdev/config_props_extractor/compare/c20a5ab37c83ec9a52258a342fbdca4c44a9ce5d...v1.2.0
[1.1.0-rc1]: https://github.com/jsilverdev/config_props_extractor/compare/20b9c43ca34750283b567afaf96cc588e766f901...v1.1.0-rc1
[1.0.0]: https://github.com/jsilverdev/config_props_extractor/compare/e31f2c8cdf0cde3b42d38d78cef492b8e3bba99a...v1.0.0
[1.0.0-rc4]: https://github.com/jsilverdev/config_props_extractor/compare/a42c67bb7a3e4de6db647d2bd9eb374c264dcc54...v1.0.0-rc4
[1.0.0-rc2]: https://github.com/jsilverdev/config_props_extractor/compare/b73a358adaba2b88f262b1e21cb597151a36a96e...v1.0.0-rc2
[1.0.0-rc1]: https://github.com/jsilverdev/config_props_extractor/releases/tag/v1.0.0-rc1