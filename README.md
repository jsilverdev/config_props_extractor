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

## Run Locally

### Requirements:

Before to run this app requires the following

- [dart](https://dart.dev/get-dart) (or [flutter](https://docs.flutter.dev/get-started/install), which includes dart)

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

5. Install dependencies

```bash
  dart pub get
```

6. Start the cli app

```bash
  dart run bin/main.dart
```

## Running Tests

To run tests, run the following command

```bash
  dart test
```

## Roadmap

- Functionality for extract from a remote git repo