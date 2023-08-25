import 'package:config_props_extractor/utils/string_utils.dart';
import 'package:test/test.dart';

void main() {
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
}
