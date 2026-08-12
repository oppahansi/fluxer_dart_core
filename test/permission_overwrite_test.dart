import 'package:fluxer_dart_core/fluxer_dart_core.dart';
import 'package:test/test.dart';

void main() {
  group('PermissionOverwrite.toJson', () {
    test('encodes type as its wire int value', () {
      const overwrite = PermissionOverwrite(
        type: PermissionOverwriteType.role,
        allow: Permissions.none,
        deny: Permissions.none,
      );

      expect(overwrite.toJson()['type'], 0);
    });

    test('encodes member type as 1', () {
      const overwrite = PermissionOverwrite(
        type: PermissionOverwriteType.member,
        allow: Permissions.none,
        deny: Permissions.none,
      );

      expect(overwrite.toJson()['type'], 1);
    });

    test('encodes allow/deny as decimal strings', () {
      final overwrite = PermissionOverwrite(
        type: PermissionOverwriteType.role,
        allow: Permissions.none.withFlag(PermissionFlag.sendMessages),
        deny: Permissions.none.withFlag(PermissionFlag.addReactions),
      );

      expect(overwrite.toJson(), {
        'type': 0,
        'allow': PermissionFlag.sendMessages.bit.toString(),
        'deny': PermissionFlag.addReactions.bit.toString(),
      });
    });
  });
}
