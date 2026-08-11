import 'package:fluxer_core/fluxer_core.dart';
import 'package:test/test.dart';

void main() {
  group('Channel.fromJson', () {
    test('decodes a guild text channel', () {
      final channel = Channel.fromJson({
        'id': '111',
        'type': 0,
        'name': 'general',
        'guild_id': '222',
        'topic': 'chat about stuff',
        'position': 0,
        'parent_id': null,
        'last_message_id': '333',
        'nsfw': false,
        'rate_limit_per_user': 5,
      });

      expect(channel, isA<GuildTextChannel>());
      final textChannel = channel as GuildTextChannel;
      expect(textChannel.id, Snowflake.parse('111'));
      expect(textChannel.name, 'general');
      expect(textChannel.guildId, Snowflake.parse('222'));
      expect(textChannel.topic, 'chat about stuff');
      expect(textChannel.lastMessageId, Snowflake.parse('333'));
      expect(textChannel.rateLimitPerUser, 5);
    });

    test('decodes a DM channel', () {
      final channel = Channel.fromJson({
        'id': '444',
        'type': 1,
        'recipients': [
          {'id': '555'},
        ],
        'last_message_id': null,
      });

      expect(channel, isA<DmChannel>());
      final dm = channel as DmChannel;
      expect(dm.recipientIds, [Snowflake.parse('555')]);
      expect(dm.lastMessageId, isNull);
    });

    test('falls back to UnknownChannel for a known-but-unmodeled type', () {
      final channel = Channel.fromJson({
        'id': '666',
        'type': 2,
        'name': 'Voice Chat',
      });

      expect(channel, isA<UnknownChannel>());
      final unknown = channel as UnknownChannel;
      expect(unknown.type, ChannelType.guildVoice);
      expect(unknown.rawType, 2);
    });

    test(
      'falls back to UnknownChannel without throwing for a totally unrecognized type',
      () {
        final channel = Channel.fromJson({
          'id': '777',
          'type': 12345,
          'name': null,
        });

        expect(channel, isA<UnknownChannel>());
        final unknown = channel as UnknownChannel;
        expect(unknown.type, isNull);
        expect(unknown.rawType, 12345);
      },
    );
  });
}
