import 'package:fluxer_core/fluxer_core.dart';
import 'package:test/test.dart';

void main() {
  test('GuildSticker.fromJson decodes a sticker', () {
    final sticker = GuildSticker.fromJson({
      'id': '1',
      'name': 'wave',
      'description': 'a waving hand',
      'tags': ['hello', 'wave'],
      'animated': false,
      'nsfw': false,
    });

    expect(sticker.id, Snowflake.parse('1'));
    expect(sticker.name, 'wave');
    expect(sticker.tags, ['hello', 'wave']);
  });
}
