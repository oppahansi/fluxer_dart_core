import 'package:fluxer_dart_core/fluxer_dart_core.dart';
import 'package:test/test.dart';

void main() {
  test('GuildEmoji.fromJson decodes an emoji', () {
    final emoji = GuildEmoji.fromJson({
      'id': '1',
      'name': 'blob',
      'animated': true,
      'nsfw': false,
    });

    expect(emoji.id, Snowflake.parse('1'));
    expect(emoji.name, 'blob');
    expect(emoji.animated, isTrue);
    expect(emoji.nsfw, isFalse);
  });
}
