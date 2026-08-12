import 'package:fluxer_dart_core/fluxer_dart_core.dart';
import 'package:test/test.dart';

void main() {
  group('ReactionEmoji.fromJson', () {
    test('decodes a custom guild emoji', () {
      final emoji = ReactionEmoji.fromJson({'id': '1', 'name': 'blob'});
      expect(emoji.isCustom, isTrue);
      expect(emoji.id, Snowflake.parse('1'));
    });

    test('decodes a standard Unicode emoji with a null id', () {
      final emoji = ReactionEmoji.fromJson({'id': null, 'name': '👍'});
      expect(emoji.isCustom, isFalse);
      expect(emoji.name, '👍');
    });
  });
}
