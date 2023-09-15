import 'dart:async';
import 'dart:io' as io;

import '../../config/logger.dart';
import '../../models/io_models.dart';
import '../exceptions.dart';

Future<void> handle(
  FutureOr<void> Function() function, {
  Exit exit = io.exit,
}) async {
  try {
    await function();
  } on AppException catch (e) {
    log.e(e);
  } catch (e, s) {
    log.f(
      'Unknown Exception: Please contact with support to fix this error',
      error: e,
      stackTrace: s,
    );
  } finally {
    exit(0);
  }
}
