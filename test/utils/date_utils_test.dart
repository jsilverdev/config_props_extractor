import 'package:clock/clock.dart';
import 'package:config_props_extractor/utils/date_utils.dart';
import 'package:test/test.dart';

void main() {
  final dateTime = DateTime(2022, 2, 2, 22, 22, 22);

  test('Should format Date for now', () async {
    // arrange
    final fixedClock = Clock.fixed(dateTime);

    // act
    final actual = withClock(
      fixedClock,
      () => formattedDate(),
    );

    // assert
    expect(actual, "2022-02-02 22:22:22");
  });

  test(
    'Should format an specific Date and dateFormat',
    () async {
      // act
      final actual = formattedDate(
        dateTime: dateTime,
        dateFormat: "yyyyMMddHHmmss",
      );
      // assert
      expect(actual, "20220202222222");
    },
  );
}
