import 'package:fluxer_core/fluxer_core.dart';
import 'package:test/test.dart';

void main() {
  group('Permissions', () {
    test('none has no flags set', () {
      expect(Permissions.none.has(PermissionFlag.sendMessages), isFalse);
      expect(Permissions.none.toSet(), isEmpty);
    });

    test('has() checks the relevant bit', () {
      final perms = Permissions(
        PermissionFlag.sendMessages.bit | PermissionFlag.viewChannel.bit,
      );
      expect(perms.has(PermissionFlag.sendMessages), isTrue);
      expect(perms.has(PermissionFlag.viewChannel), isTrue);
      expect(perms.has(PermissionFlag.manageGuild), isFalse);
    });

    test('administrator implies every other permission', () {
      final perms = Permissions(PermissionFlag.administrator.bit);
      expect(perms.has(PermissionFlag.manageGuild), isTrue);
      expect(perms.has(PermissionFlag.banMembers), isTrue);
      expect(perms.has(PermissionFlag.viewChannelMembers), isTrue);
    });

    test('fromJson parses the decimal string wire format', () {
      final raw =
          (PermissionFlag.sendMessages.bit | PermissionFlag.viewChannel.bit)
              .toString();
      final perms = Permissions.fromJson(raw);
      expect(perms.has(PermissionFlag.sendMessages), isTrue);
      expect(perms.has(PermissionFlag.viewChannel), isTrue);
    });

    test(
      'handles a permission bit beyond 32 bits (viewChannelMembers, bit 54)',
      () {
        final perms = Permissions(PermissionFlag.viewChannelMembers.bit);
        expect(perms.has(PermissionFlag.viewChannelMembers), isTrue);
        expect(Permissions.fromJson(perms.toJson()), perms);
      },
    );

    test('| combines flags, & intersects them', () {
      final a = Permissions(PermissionFlag.sendMessages.bit);
      final b = Permissions(PermissionFlag.viewChannel.bit);
      final combined = a | b;

      expect(combined.has(PermissionFlag.sendMessages), isTrue);
      expect(combined.has(PermissionFlag.viewChannel), isTrue);
      expect((combined & a).has(PermissionFlag.viewChannel), isFalse);
    });

    test('withFlag and withoutFlag round-trip', () {
      final perms = Permissions.none.withFlag(PermissionFlag.kickMembers);
      expect(perms.has(PermissionFlag.kickMembers), isTrue);
      expect(
        perms
            .withoutFlag(PermissionFlag.kickMembers)
            .has(PermissionFlag.kickMembers),
        isFalse,
      );
    });

    test('all sets every known flag', () {
      for (final flag in PermissionFlag.values) {
        expect(
          Permissions.all.has(flag),
          isTrue,
          reason: '${flag.name} should be set in Permissions.all',
        );
      }
    });
  });
}
