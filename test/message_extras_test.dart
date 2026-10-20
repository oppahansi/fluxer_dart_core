import 'package:fluxer_dart_core/fluxer_dart_core.dart';
import 'package:test/test.dart';

// Recorded MESSAGE_CREATE: the member carries no user of its own.
const _gatewayMessage = {
  'attachments': <dynamic>[],
  'author': {
    'avatar': null,
    'avatar_color': null,
    'bot': true,
    'discriminator': '9784',
    'flags': 0,
    'global_name': null,
    'id': '1536790964075495424',
    'username': 'MarlinMammut',
  },
  'channel_id': '1536791058510249987',
  'channel_type': 0,
  'content': 'rec m11 starter',
  'edited_timestamp': null,
  'embeds': <dynamic>[],
  'flags': 0,
  'guild_id': '1536791058510249984',
  'id': '1562165912151261184',
  'member': {
    'accent_color': null,
    'avatar': null,
    'banner': null,
    'communication_disabled_until': null,
    'deaf': false,
    'guild_id': '1536791058510249984',
    'joined_at': '2026-08-12T06:10:10.527Z',
    'mute': false,
    'nick': null,
    'roles': ['1546623715096133632'],
  },
  'mention_everyone': false,
  'mention_roles': <dynamic>[],
  'mentions': <dynamic>[],
  'pinned': false,
  'stickers': <dynamic>[],
  'timestamp': '2026-10-20T18:09:37.096Z',
  'tts': false,
  'type': 0,
};

void main() {
  test('a gateway message fills its member from the author', () {
    final message = Message.fromJson(_gatewayMessage);

    expect(message.guildId, Snowflake.parse('1536791058510249984'));
    expect(message.member!.user.id, message.author.id);
    expect(message.isWebhook, isFalse);
  });

  test('webhook id, stickers, reactions and nonce', () {
    final message = Message.fromJson({
      ..._gatewayMessage,
      'webhook_id': '7',
      'nonce': 'n1',
      'stickers': [
        {'id': '8', 'name': 's', 'animated': false},
      ],
      'reactions': [
        {
          'emoji': {'name': '👍'},
          'count': 2,
          'me': true,
        },
      ],
    });

    expect(message.isWebhook, isTrue);
    expect(message.nonce, 'n1');
    expect(message.stickers.single.name, 's');
    expect(message.reactions.single.count, 2);
    expect(message.reactions.single.me, isTrue);
  });
}
