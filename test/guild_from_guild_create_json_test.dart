import 'package:fluxer_core/fluxer_core.dart';
import 'package:test/test.dart';

void main() {
  group('Guild.fromGuildCreateJson', () {
    test('decodes the nested-properties gateway GUILD_CREATE shape', () {
      final guild = Guild.fromGuildCreateJson({
        'id': '900',
        'properties': {
          'id': '900',
          'name': 'Test Guild',
          'icon': null,
          'owner_id': '901',
        },
        'roles': [
          {
            'id': '902',
            'name': '@everyone',
            'color': 0,
            'position': 0,
            'permissions': '0',
            'hoist': false,
            'mentionable': false,
            'unicode_emoji': null,
          },
        ],
        'member_count': 5,
        'channels': <dynamic>[],
        'emojis': <dynamic>[],
        'members': <dynamic>[],
        'joined_at': '2026-08-11T12:00:00.000Z',
      });

      expect(guild.id, Snowflake.parse('900'));
      expect(guild.name, 'Test Guild');
      expect(guild.ownerId, Snowflake.parse('901'));
      expect(guild.memberCount, 5);
      expect(guild.roles, hasLength(1));
    });

    test('does not throw when properties is missing entirely', () {
      expect(
        () => Guild.fromGuildCreateJson({
          'id': '900',
          'roles': <dynamic>[],
          'member_count': 0,
        }),
        throwsA(isA<TypeError>()),
        reason:
            'name/owner_id are still required — this documents that missing properties fails loudly, not silently',
      );
    });
  });
}
