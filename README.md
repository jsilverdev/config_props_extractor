# Config Properties Extractor

Simple command-line application to get properties from ConfigMaps and Secrets

## Features

- Run without need to install dart (compiled files)
- Cross platform

## Environment Variables

To run this project, you will need to add the following environment variables to your .env file

`GIT_REPO_PATH` Required. Selected folder that contain config folders

`GIT_BRANCH` Optional. By default is the current branch

`GIT_SSL_ENABLED` Optional. By default is true

`GIT_FORCE_REMOTE` Optional. By default is false

`CONFIG_MAPS_PATH` Optional. By default is 'configMap'

`SECRETS_PATH` Optional. By default is 'secret'

`MAX_DURATION_IN_MIN` Optional. For remote  By default is 3

## Run Locally

### Requirements:

Before to run this app requires the following

- [git](https://git-scm.com/downloads)
- [dart](https://dart.dev/get-dart) (or [flutter](https://docs.flutter.dev/get-started/install), which includes dart) (Optional)

### Steps:

1. Clone the project

```bash
  git clone https://github.com/jsilverdev/config_props_extractor.git
```

2. Go to the project directory

```bash
  cd config_props_extractor
```

3. Create .env from the .env.example

```bash
  cp .env.example .env
```

4. Define the `GIT_REPO_PATH` in the .env file

```dotenv
  GIT_REPO_PATH="path/to/config_folder_path"
```

5. Install dependencies (if you don´t have dart go to the [Run binaries section](#run-binaries))

```bash
  dart pub get
```

6. Start the cli app

```bash
  dart run bin/main.dart
```

### Run binaries

You can download the binaries on the [releases](https://github.com/jsilverdev/config_props_extractor/releases) section.

Or git checkout to a desired tag (for example v1.0.0):

```bash
  git checkout tags/v1.0.0
```

And then run the binary for your platform

```bash
  .\run-win.exe
  ./run-macos
  ./run-linux
```

## Running Tests

To run tests, run the following command

```bash
  dart test
```

If you want run tests with coverage, install [coverage](https://pub.dev/packages/coverage) globally

```bash
  dart pub global activate coverage
```

Then run

```bash
  dart pub global run coverage:test_with_coverage --function-coverage --branch-coverage
```

If you want to see a way to visualize this in a html page, you can use lcov for [Linux](https://github.com/linux-test-project/lcov) or [Mac](https://formulae.brew.sh/formula/lcov). If you are on Windows, you can use [jgenhtml](https://github.com/ricksbrown/jgenhtml) and then run

```bash
  genhtml -o coverage coverage/lcov.info
```