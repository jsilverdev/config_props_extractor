import 'dart:async';

import '../../config/logger.dart';
import '../exceptions.dart';

Future<void> handle(FutureOr<void> Function() function) async {
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
  }
}
