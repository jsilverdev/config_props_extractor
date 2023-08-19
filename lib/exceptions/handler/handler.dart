import 'dart:io';

import '../exceptions.dart';

class Handler {
  void handle(Function function) {
    try {
      function();
    } on AppException catch (e) {
      stderr.writeln(e.toString());
    } catch (e, s) {
      stderr.writeln('Unknown exception:\n $e');
      stderr.writeln('Stack trace:\n $s');
    }
  }
}
