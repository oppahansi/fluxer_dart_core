import 'package:fluxer_dart_core/fluxer_dart_core.dart';
import 'package:test/test.dart';

void main() {
  group('Snowflake', () {
    test('parses from a decimal string', () {
      final snowflake = Snowflake.parse('175928847299117063');
      expect(snowflake.value, 175928847299117063);
    });

    test('extracts the creation timestamp from the embedded bits', () {
      // A snowflake minted exactly 1,000,000ms after the Fluxer epoch,
      // with worker/sequence bits zeroed.
      final snowflake = Snowflake(1000000 << 22);
      expect(
        snowflake.timestamp,
        DateTime.fromMillisecondsSinceEpoch(
          fluxerEpochMs + 1000000,
          isUtc: true,
        ),
      );
    });

    test('two snowflakes with the same value are equal', () {
      expect(Snowflake(123), Snowflake(123));
      expect(Snowflake(123).hashCode, Snowflake(123).hashCode);
    });

    test('toJson round-trips through Snowflake.parse', () {
      final original = Snowflake.parse('175928847299117063');
      expect(Snowflake.parse(original.toJson()), original);
    });
  });
}
