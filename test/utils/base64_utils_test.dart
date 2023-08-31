import 'package:config_props_extractor/utils/base64_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Decode Base64', () {
    test(
      'Should decode encoded String',
      () async {
        // arrange
        final encoded = "ZXhwZWN0ZWQ=";
        // act
        final result = tryBase64Decode(encoded);
        // assert
        expect(result, equals("expected"));
      },
    );

    test(
      'Should return null if decoding fails',
      () async {
        // arrange
        final badEncoded = "ZXhwZWN0ZWQ=1d1d12sds";
        bool executed = false;
        // act
        final result = tryBase64Decode(
          badEncoded,
          onFailed: () => executed = true,
        );
        // assert
        expect(result, isNull);
        expect(executed, equals(true));
      },
    );
  });
}
