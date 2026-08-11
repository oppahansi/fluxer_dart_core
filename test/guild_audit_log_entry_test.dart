import 'package:fluxer_dart_core/fluxer_dart_core.dart';
import 'package:test/test.dart';

void main() {
  group('GuildAuditLogEntry.fromJson', () {
    test('decodes the required fields', () {
      final entry = GuildAuditLogEntry.fromJson({'id': '1', 'action_type': 10});

      expect(entry.id, Snowflake.parse('1'));
      expect(entry.actionType, 10);
      expect(entry.userId, isNull);
      expect(entry.targetId, isNull);
      expect(entry.reason, isNull);
      expect(entry.options, isEmpty);
    });

    test('decodes optional fields when present', () {
      final entry = GuildAuditLogEntry.fromJson({
        'id': '1',
        'action_type': 10,
        'user_id': '2',
        'target_id': '3',
        'reason': 'spamming',
        'options': {'channel_id': '4'},
      });

      expect(entry.userId, Snowflake.parse('2'));
      expect(entry.targetId, '3');
      expect(entry.reason, 'spamming');
      expect(entry.options, {'channel_id': '4'});
    });

    test('equality is by id', () {
      final a = GuildAuditLogEntry.fromJson({'id': '1', 'action_type': 10});
      final b = GuildAuditLogEntry.fromJson({'id': '1', 'action_type': 20});

      expect(a, b);
    });
  });
}
