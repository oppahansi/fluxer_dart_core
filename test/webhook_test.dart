import 'package:fluxer_core/fluxer_core.dart';
import 'package:test/test.dart';

void main() {
  test('Webhook.fromJson decodes a webhook', () {
    final webhook = Webhook.fromJson({
      'id': '1',
      'guild_id': '2',
      'channel_id': '3',
      'name': 'CI Bot',
      'avatar': null,
      'token': 'secret-token',
      'user': {
        'id': '4',
        'username': 'oppa',
        'discriminator': '0',
        'global_name': null,
        'avatar': null,
        'avatar_color': null,
        'bot': false,
        'system': false,
      },
    });

    expect(webhook.id, Snowflake.parse('1'));
    expect(webhook.guildId, Snowflake.parse('2'));
    expect(webhook.channelId, Snowflake.parse('3'));
    expect(webhook.name, 'CI Bot');
    expect(webhook.token, 'secret-token');
    expect(webhook.creator.username, 'oppa');
  });
}
