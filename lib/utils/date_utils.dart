import 'package:clock/clock.dart';
import 'package:intl/intl.dart';


String formattedDate([DateTime? dateTime]) {
  return DateFormat('yyyy-MM-dd H:mm:ss').format(
    dateTime ?? clock.now(),
  );
}
