import 'dart:io';

import 'utils/dagger_gql_client.dart';
import 'utils/simple_handler.dart';

void main(List<String> args) {
  ciHandle(() => testing());
}

void testing() async {
  final int minCoverage = 85;

  final client = DaggerGQLClient();

  // Choose container
  var runtime = await client.executeQuery('''
       query {
        container {
          from (address: "dart:3-sdk") {
            id
          }
        }
      }
  ''');

  final hostDir = await client.executeQuery('''
      query {
          host {
            directory (path: ".", exclude: [".dart_tool", "ci", "coverage"]) {
              id
            }
          }
      }
  ''');

  // Install Deps
  runtime = await client.executeQuery('''
      query {
        container(id: "$runtime") {
          withDirectory(path: "/app", directory: "$hostDir") {
            withWorkdir(path: "/app") {
              withExec(args: ["dart", "pub", "get"]) {
                id
              }
            }
          }
        }
      }
  ''');

  // Analyze project source
  runtime = await client.executeQuery('''
    query {
      container(id: "$runtime") {
        withExec(args: ["dart", "analyze"]) {
          id
        }
      }
    }
  ''');

  // Add global dependencies
  runtime = await client.executeQuery('''
    query {
      container(id: "$runtime") {
        withExec(args: ["dart", "pub", "global", "activate", "dlcov", "<5.0.0"]) {
          withExec(args: ["dart", "pub", "global", "activate", "coverage", "<2.0.0"]) {
            id
          }
        }
      }
    }
  ''');

  // Run Tests
  runtime = await client.executeQuery('''
    query {
      container(id: "$runtime") {
        withExec(args: [
          "test_with_coverage",
          "--function-coverage",
          "--branch-coverage"
        ]) {
          id
        }
      }
    }
  ''');

  // Analyze Coverage
  runtime = await client.executeQuery('''
    query {
      container(id: "$runtime") {
        withExec(args: [
          "dlcov",
          "--coverage=$minCoverage",
          "--include-untested-files=true"
        ]) {
          stdout
        }
      }
    }
  ''');

  stdout.writeln(runtime);
}
