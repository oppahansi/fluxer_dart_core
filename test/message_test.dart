import 'package:fluxer_dart_core/fluxer_dart_core.dart';
import 'package:test/test.dart';

Map<String, dynamic> _sampleUserJson({String id = '1'}) => {
  'id': id,
  'username': 'oppa',
  'discriminator': '0',
  'global_name': 'Oppa',
  'avatar': null,
  'avatar_color': null,
  'bot': false,
  'system': false,
};

void main() {
  group('Message.fromJson', () {
    test('decodes a plain text message', () {
      final message = Message.fromJson({
        'id': '100',
        'channel_id': '200',
        'author': _sampleUserJson(),
        'type': 0,
        'flags': 0,
        'content': '!ping',
        'timestamp': '2026-08-11T12:00:00.000Z',
        'edited_timestamp': null,
        'pinned': false,
        'mention_everyone': false,
        'tts': false,
        'mentions': <dynamic>[],
        'mention_roles': <dynamic>[],
      });

      expect(message.id, Snowflake.parse('100'));
      expect(message.channelId, Snowflake.parse('200'));
      expect(message.author.username, 'oppa');
      expect(message.content, '!ping');
      expect(message.editedTimestamp, isNull);
      expect(message.mentions, isEmpty);
    });

    test('decodes flags via hasFlag', () {
      final message = Message.fromJson({
        'id': '100',
        'channel_id': '200',
        'author': _sampleUserJson(),
        'type': 0,
        'flags': MessageFlag.voiceMessage.bit | MessageFlag.suppressEmbeds.bit,
        'content': '',
        'timestamp': '2026-08-11T12:00:00.000Z',
        'edited_timestamp': null,
        'pinned': false,
        'mention_everyone': false,
        'tts': false,
        'mentions': <dynamic>[],
        'mention_roles': <dynamic>[],
      });

      expect(message.hasFlag(MessageFlag.voiceMessage), isTrue);
      expect(message.hasFlag(MessageFlag.suppressEmbeds), isTrue);
      expect(message.hasFlag(MessageFlag.suppressNotifications), isFalse);
    });

    test('decodes mentions and mention role IDs', () {
      final message = Message.fromJson({
        'id': '100',
        'channel_id': '200',
        'author': _sampleUserJson(),
        'type': 0,
        'flags': 0,
        'content': '@oppa hi',
        'timestamp': '2026-08-11T12:00:00.000Z',
        'edited_timestamp': null,
        'pinned': false,
        'mention_everyone': false,
        'tts': false,
        'mentions': [_sampleUserJson(id: '2')],
        'mention_roles': ['300'],
      });

      expect(message.mentions.single.id, Snowflake.parse('2'));
      expect(message.mentionRoleIds, [Snowflake.parse('300')]);
    });
  });
}
