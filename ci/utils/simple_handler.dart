import 'dart:async';
import 'dart:io';

Future<void> ciHandle(FutureOr<void> Function() function) async {
  try {
    await function();
    exit(0);
  } catch (e) {
    stderr.writeln("Exception: $e");
    exit(255);
  }
}
