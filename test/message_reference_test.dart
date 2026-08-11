import 'package:fluxer_dart_core/fluxer_dart_core.dart';
import 'package:test/test.dart';

void main() {
  group('MessageReference', () {
    test('fromJson decodes messageId only', () {
      final ref = MessageReference.fromJson({'message_id': '100'});

      expect(ref.messageId, Snowflake.parse('100'));
      expect(ref.channelId, isNull);
      expect(ref.guildId, isNull);
    });

    test('fromJson decodes channelId and guildId when present', () {
      final ref = MessageReference.fromJson({
        'message_id': '100',
        'channel_id': '200',
        'guild_id': '300',
      });

      expect(ref.channelId, Snowflake.parse('200'));
      expect(ref.guildId, Snowflake.parse('300'));
    });

    test('toJson omits channelId/guildId when unset', () {
      const ref = MessageReference(messageId: Snowflake(100));

      expect(ref.toJson(), {'message_id': '100'});
    });

    test('toJson includes channelId/guildId when set', () {
      const ref = MessageReference(
        messageId: Snowflake(100),
        channelId: Snowflake(200),
        guildId: Snowflake(300),
      );

      expect(ref.toJson(), {
        'message_id': '100',
        'channel_id': '200',
        'guild_id': '300',
      });
    });
  });
}
