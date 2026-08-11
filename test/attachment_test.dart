import 'package:fluxer_dart_core/fluxer_dart_core.dart';
import 'package:test/test.dart';

void main() {
  group('Attachment.fromJson', () {
    test('decodes the required fields', () {
      final attachment = Attachment.fromJson({
        'id': '400',
        'filename': 'cat.png',
        'size': 1024,
      });

      expect(attachment.id, Snowflake.parse('400'));
      expect(attachment.filename, 'cat.png');
      expect(attachment.size, 1024);
      expect(attachment.url, isNull);
    });

    test('decodes optional fields when present', () {
      final attachment = Attachment.fromJson({
        'id': '400',
        'filename': 'cat.png',
        'size': 1024,
        'content_type': 'image/png',
        'url': 'https://example.com/cat.png',
        'proxy_url': 'https://proxy.example.com/cat.png',
        'width': 64,
        'height': 64,
        'description': 'A cat',
      });

      expect(attachment.contentType, 'image/png');
      expect(attachment.width, 64);
      expect(attachment.height, 64);
      expect(attachment.description, 'A cat');
    });

    test('equality is by id', () {
      final a = Attachment.fromJson({'id': '1', 'filename': 'a', 'size': 1});
      final b = Attachment.fromJson({'id': '1', 'filename': 'b', 'size': 2});

      expect(a, b);
    });
  });
}
