import 'package:fluxer_dart_core/fluxer_dart_core.dart';
import 'package:test/test.dart';

void main() {
  group('UserPresence.fromJson', () {
    test('decodes a presence from a member chunk', () {
      // Recorded from GUILD_MEMBERS_CHUNK with presences requested.
      final presence = UserPresence.fromJson({
        'afk': false,
        'custom_status': null,
        'mobile': false,
        'status': 'online',
        'user': {
          'avatar': null,
          'avatar_color': null,
          'bot': true,
          'discriminator': '9784',
          'flags': 0,
          'global_name': null,
          'id': '1536790964075495424',
          'username': 'MarlinMammut',
        },
      });

      expect(presence.user.id, Snowflake.parse('1536790964075495424'));
      expect(presence.status, PresenceStatus.online);
      expect(presence.mobile, isFalse);
      expect(presence.afk, isFalse);
      expect(presence.customStatus, isNull);
      expect(presence.guildId, isNull);
    });

    test('decodes a custom status and guild context', () {
      final presence = UserPresence.fromJson({
        'user': {'id': '1', 'username': 'u', 'discriminator': '0001'},
        'status': 'dnd',
        'mobile': false,
        'afk': true,
        'guild_id': '2',
        'custom_status': {
          'text': 'busy',
          'expires_at': null,
          'emoji_id': '3',
          'emoji_name': 'party',
          'emoji_animated': true,
        },
      });

      expect(presence.status, PresenceStatus.doNotDisturb);
      expect(presence.guildId, Snowflake.parse('2'));
      expect(presence.customStatus!.text, 'busy');
      expect(presence.customStatus!.emojiId, Snowflake.parse('3'));
      expect(presence.customStatus!.emojiAnimated, isTrue);
    });

    test('an unrecognised status decodes as offline', () {
      final presence = UserPresence.fromJson({
        'user': {'id': '1', 'username': 'u', 'discriminator': '0001'},
        'status': 'something-new',
      });

      expect(presence.status, PresenceStatus.offline);
    });
  });

  group('GuildRole.fromJson', () {
    Map<String, dynamic> role(Object? hoistPosition) => {
      'id': '1562162800980131844',
      'name': 'rec-r1b',
      'color': 3368703,
      'position': 2,
      'hoist_position': hoistPosition,
      'permissions': '18014914009747009',
      'hoist': true,
      'mentionable': true,
    };

    test('decodes hoist_position and tolerates an absent unicode_emoji', () {
      final decoded = GuildRole.fromJson(role(1));

      expect(decoded.hoistPosition, 1);
      expect(decoded.unicodeEmoji, isNull);
    });

    test('hoist_position is null until set', () {
      expect(GuildRole.fromJson(role(null)).hoistPosition, isNull);
    });
  });

  group('UserPresence.fromJson placeholder', () {
    const user = User(
      id: Snowflake(1),
      username: 'u',
      discriminator: '0001',
      globalName: null,
      avatar: null,
      avatarColor: null,
      bot: false,
      system: false,
    );

    test('takes the supplied user when the presence has none', () {
      final presence = UserPresence.fromJson({
        'status': 'offline',
        'mobile': false,
        'afk': false,
      }, user: user);

      expect(presence.user.id, const Snowflake(1));
      expect(presence.status, PresenceStatus.offline);
    });

    test('throws a FormatException with neither', () {
      expect(
        () => UserPresence.fromJson({'status': 'offline'}),
        throwsFormatException,
      );
    });
  });
}
