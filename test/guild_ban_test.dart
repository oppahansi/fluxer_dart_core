import 'package:fluxer_dart_core/fluxer_dart_core.dart';
import 'package:test/test.dart';

Map<String, dynamic> _sampleUserJson() => {
  'id': '1',
  'username': 'baduser',
  'discriminator': '0',
  'global_name': null,
  'avatar': null,
  'avatar_color': null,
  'bot': false,
  'system': false,
};

void main() {
  group('GuildBan.fromJson', () {
    test('decodes a permanent ban with a reason', () {
      final ban = GuildBan.fromJson({
        'user': _sampleUserJson(),
        'reason': 'spamming',
        'moderator_id': '2',
        'banned_at': '2026-08-11T12:00:00.000Z',
        'expires_at': null,
      });

      expect(ban.reason, 'spamming');
      expect(ban.moderatorId, Snowflake.parse('2'));
      expect(ban.expiresAt, isNull);
    });

    test('decodes a temporary ban', () {
      final ban = GuildBan.fromJson({
        'user': _sampleUserJson(),
        'reason': null,
        'moderator_id': '2',
        'banned_at': '2026-08-11T12:00:00.000Z',
        'expires_at': '2026-08-18T12:00:00.000Z',
      });

      expect(ban.expiresAt, DateTime.parse('2026-08-18T12:00:00.000Z'));
    });
  });
}
