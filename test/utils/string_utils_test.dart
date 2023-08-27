import 'package:config_props_extractor/utils/string_utils.dart';
import 'package:test/test.dart';

void main() {
  group('toBoolean', () {
    test(
      'Should parse to bool for String using ToBooleanExtension',
      () async {
        // arrange
        String value = "true";
        // act
        bool actual = value.toBoolean();
        // assert
        expect(actual, equals(true));
      },
    );

    test(
      'Should result to false if String value is not correct boolean using ToBooleanExtension',
      () async {
        // arrange
        String value = "no_valid";
        // act
        bool actual = value.toBoolean();
        // assert
        expect(actual, equals(false));
      },
    );
  });

  group('format', () {

    test(
      'Should interpolate with only {}',
      () async {
        // arrange
        final stringValue = "{} {} {}";
        final toInterpolate = ["value1", "value2", "value3"];
        // act
        final actual = stringValue.format(toInterpolate);
        // assert
        expect(actual, equals("value1 value2 value3"));
      },
    );


    test(
      'Should interpolate with numbers {n}',
      () async {
        // arrange
        final stringValue = "{2} {3} {1}";
        final toInterpolate = ["value3", "value1", "value2"];
        // act
        final actual = stringValue.format(toInterpolate);
        // assert
        expect(actual, equals("value1 value2 value3"));
      },
    );

  });
}
