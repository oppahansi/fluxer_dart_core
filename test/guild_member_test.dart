import 'package:fluxer_core/fluxer_core.dart';
import 'package:test/test.dart';

Map<String, dynamic> _sampleUserJson() => {
  'id': '1',
  'username': 'oppa',
  'discriminator': '0',
  'global_name': 'Oppa',
  'avatar': null,
  'avatar_color': null,
  'bot': false,
  'system': false,
};

void main() {
  group('GuildMember.fromJson', () {
    test('decodes a member with no nickname or timeout', () {
      final member = GuildMember.fromJson({
        'user': _sampleUserJson(),
        'nick': null,
        'avatar': null,
        'roles': ['10', '11'],
        'joined_at': '2026-08-11T12:00:00.000Z',
        'mute': false,
        'deaf': false,
        'communication_disabled_until': null,
      });

      expect(member.nick, isNull);
      expect(member.displayName, 'Oppa');
      expect(member.roleIds, [Snowflake.parse('10'), Snowflake.parse('11')]);
      expect(member.isTimedOut, isFalse);
    });

    test('nick overrides displayName when set', () {
      final member = GuildMember.fromJson({
        'user': _sampleUserJson(),
        'nick': 'Big O',
        'avatar': null,
        'roles': <dynamic>[],
        'joined_at': '2026-08-11T12:00:00.000Z',
        'mute': false,
        'deaf': false,
        'communication_disabled_until': null,
      });

      expect(member.displayName, 'Big O');
    });

    test('isTimedOut reflects a future communication_disabled_until', () {
      final future = DateTime.now()
          .add(const Duration(hours: 1))
          .toIso8601String();
      final member = GuildMember.fromJson({
        'user': _sampleUserJson(),
        'nick': null,
        'avatar': null,
        'roles': <dynamic>[],
        'joined_at': '2026-08-11T12:00:00.000Z',
        'mute': false,
        'deaf': false,
        'communication_disabled_until': future,
      });

      expect(member.isTimedOut, isTrue);
    });

    test('isTimedOut is false for a past communication_disabled_until', () {
      final past = DateTime.now()
          .subtract(const Duration(hours: 1))
          .toIso8601String();
      final member = GuildMember.fromJson({
        'user': _sampleUserJson(),
        'nick': null,
        'avatar': null,
        'roles': <dynamic>[],
        'joined_at': '2026-08-11T12:00:00.000Z',
        'mute': false,
        'deaf': false,
        'communication_disabled_until': past,
      });

      expect(member.isTimedOut, isFalse);
    });
  });
}
