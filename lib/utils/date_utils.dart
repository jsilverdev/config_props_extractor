import 'package:clock/clock.dart';
import 'package:intl/intl.dart';

String formattedDate({
  DateTime? dateTime,
  String dateFormat = 'yyyy-MM-dd H:mm:ss',
}) {
  return DateFormat(dateFormat).format(
    dateTime ?? clock.now(),
  );
}
