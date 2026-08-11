import 'package:fluxer_dart_core/fluxer_dart_core.dart';
import 'package:test/test.dart';

void main() {
  group('Guild.fromJson', () {
    test('decodes identity, ownership, and roles', () {
      final guild = Guild.fromJson({
        'id': '900',
        'name': 'Test Guild',
        'icon': null,
        'owner_id': '901',
        'member_count': 42,
        'roles': [
          {
            'id': '902',
            'name': '@everyone',
            'color': 0,
            'position': 0,
            'permissions': PermissionFlag.viewChannel.bit.toString(),
            'hoist': false,
            'mentionable': false,
            'unicode_emoji': null,
          },
        ],
      });

      expect(guild.id, Snowflake.parse('900'));
      expect(guild.name, 'Test Guild');
      expect(guild.ownerId, Snowflake.parse('901'));
      expect(guild.memberCount, 42);
      expect(guild.roles, hasLength(1));
      expect(guild.roles.single.name, '@everyone');
      expect(
        guild.roles.single.permissions.has(PermissionFlag.viewChannel),
        isTrue,
      );
    });

    test('defaults roles to empty when omitted', () {
      final guild = Guild.fromJson({
        'id': '900',
        'name': 'Test Guild',
        'icon': null,
        'owner_id': '901',
        'member_count': null,
      });

      expect(guild.roles, isEmpty);
      expect(guild.memberCount, isNull);
    });
  });
}
