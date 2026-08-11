import 'package:fluxer_dart_core/fluxer_dart_core.dart';
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

    test('decodes a guild voice channel', () {
      final channel = Channel.fromJson({
        'id': '666',
        'type': 2,
        'name': 'Voice Chat',
        'guild_id': '222',
        'position': 1,
        'parent_id': null,
        'bitrate': 64000,
        'user_limit': 10,
        'voice_connection_limit': null,
        'rtc_region': null,
      });

      expect(channel, isA<GuildVoiceChannel>());
      final voice = channel as GuildVoiceChannel;
      expect(voice.name, 'Voice Chat');
      expect(voice.bitrate, 64000);
      expect(voice.userLimit, 10);
    });

    test('decodes a group DM channel', () {
      final channel = Channel.fromJson({
        'id': '888',
        'type': 3,
        'name': 'Trip planning',
        'icon': null,
        'owner_id': '999',
        'recipients': [
          {'id': '111'},
          {'id': '222'},
        ],
        'last_message_id': null,
      });

      expect(channel, isA<GroupDmChannel>());
      final groupDm = channel as GroupDmChannel;
      expect(groupDm.name, 'Trip planning');
      expect(groupDm.ownerId, Snowflake.parse('999'));
      expect(groupDm.recipientIds, [
        Snowflake.parse('111'),
        Snowflake.parse('222'),
      ]);
    });

    test('decodes a guild category channel', () {
      final channel = Channel.fromJson({
        'id': '333',
        'type': 4,
        'name': 'Text Channels',
        'guild_id': '222',
        'position': 0,
      });

      expect(channel, isA<GuildCategoryChannel>());
      expect((channel as GuildCategoryChannel).name, 'Text Channels');
    });

    test(
      'falls back to UnknownChannel for a known-but-unmodeled type (dmPersonalNotes)',
      () {
        final channel = Channel.fromJson({
          'id': '667',
          'type': 999,
          'name': null,
        });

        expect(channel, isA<UnknownChannel>());
        final unknown = channel as UnknownChannel;
        expect(unknown.type, ChannelType.dmPersonalNotes);
        expect(unknown.rawType, 999);
      },
    );

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
