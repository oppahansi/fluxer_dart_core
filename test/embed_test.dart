import 'package:fluxer_dart_core/fluxer_dart_core.dart';
import 'package:test/test.dart';

void main() {
  group('Embed', () {
    test('fromJson decodes every field', () {
      final embed = Embed.fromJson({
        'title': 'Title',
        'description': 'Description',
        'url': 'https://example.com',
        'color': 0x4641d9,
        'timestamp': '2026-08-11T12:00:00.000Z',
        'author': {'name': 'Author', 'icon_url': 'https://example.com/a.png'},
        'footer': {'text': 'Footer'},
        'image': {'url': 'https://example.com/image.png', 'width': 100},
        'thumbnail': {'url': 'https://example.com/thumb.png'},
        'fields': [
          {'name': 'f1', 'value': 'v1', 'inline': true},
          {'name': 'f2', 'value': 'v2'},
        ],
      });

      expect(embed.title, 'Title');
      expect(embed.description, 'Description');
      expect(embed.url, 'https://example.com');
      expect(embed.color, 0x4641d9);
      expect(embed.timestamp, DateTime.parse('2026-08-11T12:00:00.000Z'));
      expect(embed.author?.name, 'Author');
      expect(embed.footer?.text, 'Footer');
      expect(embed.image?.width, 100);
      expect(embed.thumbnail?.url, 'https://example.com/thumb.png');
      expect(embed.fields, hasLength(2));
      expect(embed.fields[0].inline, isTrue);
      expect(embed.fields[1].inline, isFalse);
    });

    test('fromJson tolerates every field being absent', () {
      final embed = Embed.fromJson({});

      expect(embed.title, isNull);
      expect(embed.fields, isEmpty);
    });

    test('toJson only emits set fields, omitting nulls and empty fields', () {
      const embed = Embed(title: 'Title');

      expect(embed.toJson(), {'title': 'Title'});
    });

    test('toJson round-trips a fully populated embed', () {
      const embed = Embed(
        title: 'Title',
        description: 'Description',
        color: 0x4641d9,
        author: EmbedAuthor(name: 'Author'),
        footer: EmbedFooter(text: 'Footer'),
        fields: [EmbedField(name: 'f1', value: 'v1', inline: true)],
      );

      final decoded = Embed.fromJson(embed.toJson());

      expect(decoded.title, 'Title');
      expect(decoded.author?.name, 'Author');
      expect(decoded.footer?.text, 'Footer');
      expect(decoded.fields.single.name, 'f1');
    });

    test(
      'EmbedMedia.toJson only emits url and description, not response-only fields',
      () {
        const media = EmbedMedia(
          url: 'https://example.com/x.png',
          proxyUrl: 'https://proxy.example.com/x.png',
          width: 10,
          height: 10,
        );

        expect(media.toJson(), {'url': 'https://example.com/x.png'});
      },
    );
  });
}
