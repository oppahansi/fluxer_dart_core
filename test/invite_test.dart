import 'package:fluxer_dart_core/fluxer_dart_core.dart';
import 'package:test/test.dart';

void main() {
  group('Invite.fromJson', () {
    test('decodes a full invite with guild, channel, and inviter', () {
      final invite = Invite.fromJson({
        'code': 'abc123',
        'type': 0,
        'guild': {'id': '1', 'name': 'Test Guild'},
        'channel': {
          'id': '2',
          'name': 'general',
          'type': 0,
          'recipients': <dynamic>[],
        },
        'inviter': {
          'id': '3',
          'username': 'oppa',
          'discriminator': '0',
          'global_name': null,
          'avatar': null,
          'avatar_color': null,
          'bot': false,
          'system': false,
        },
        'member_count': 5,
        'presence_count': 2,
        'expires_at': '2026-08-18T12:00:00.000Z',
        'temporary': false,
      });

      expect(invite.code, 'abc123');
      expect(invite.guildId, Snowflake.parse('1'));
      expect(invite.guildName, 'Test Guild');
      expect(invite.channelId, Snowflake.parse('2'));
      expect(invite.channelName, 'general');
      expect(invite.inviter!.username, 'oppa');
      expect(invite.expiresAt, DateTime.parse('2026-08-18T12:00:00.000Z'));
    });

    test(
      'decodes an invite with no guild (DM/group DM invite) and no expiry',
      () {
        final invite = Invite.fromJson({
          'code': 'xyz789',
          'type': 1,
          'guild': null,
          'channel': {
            'id': '2',
            'name': null,
            'type': 3,
            'recipients': <dynamic>[],
          },
          'inviter': null,
          'member_count': 2,
          'presence_count': 1,
          'expires_at': null,
          'temporary': false,
        });

        expect(invite.guildId, isNull);
        expect(invite.inviter, isNull);
        expect(invite.expiresAt, isNull);
      },
    );
  });
}
