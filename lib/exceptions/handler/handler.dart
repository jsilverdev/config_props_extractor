import 'dart:async';

import '../../logger/app_logger.dart';
import '../exceptions.dart';

Future<void> handle(FutureOr<void> Function() function) async {
  try {
    await function();
  } on AppException catch (e) {
    logger.e(e);
  } catch (e, s) {
    logger.f(
      'Unknown Exception: Please contact with support to fix this error',
      error: e,
      stackTrace: s,
    );
  }
}
