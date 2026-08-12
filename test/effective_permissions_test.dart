import 'package:fluxer_dart_core/fluxer_dart_core.dart';
import 'package:test/test.dart';

const _guildId = Snowflake(1);
const _ownerId = Snowflake(2);
const _memberId = Snowflake(3);

const _everyoneRole = GuildRole(
  id: _guildId,
  name: '@everyone',
  color: 0,
  position: 0,
  permissions: Permissions(0),
  hoist: false,
  mentionable: false,
  unicodeEmoji: null,
);

const _member = User(
  id: _memberId,
  username: 'member',
  discriminator: '0',
  globalName: null,
  avatar: null,
  avatarColor: null,
  bot: false,
  system: false,
);

GuildMember _guildMember({List<Snowflake> roleIds = const []}) => GuildMember(
  user: _member,
  nick: null,
  avatar: null,
  roleIds: roleIds,
  joinedAt: DateTime.utc(2026),
  mute: false,
  deaf: false,
  communicationDisabledUntil: null,
);

void main() {
  group('effectiveGuildPermissions', () {
    test('the guild owner always gets every permission', () {
      final owner = GuildMember(
        user: const User(
          id: _ownerId,
          username: 'owner',
          discriminator: '0',
          globalName: null,
          avatar: null,
          avatarColor: null,
          bot: false,
          system: false,
        ),
        nick: null,
        avatar: null,
        roleIds: const [],
        joinedAt: DateTime.utc(2026),
        mute: false,
        deaf: false,
        communicationDisabledUntil: null,
      );

      final perms = effectiveGuildPermissions(
        member: owner,
        guildId: _guildId,
        guildOwnerId: _ownerId,
        roles: const [_everyoneRole],
      );

      expect(perms.has(PermissionFlag.administrator), isTrue);
      expect(perms.has(PermissionFlag.banMembers), isTrue);
    });

    test('a non-owner gets @everyone permissions even without holding it', () {
      final perms = effectiveGuildPermissions(
        member: _guildMember(),
        guildId: _guildId,
        guildOwnerId: _ownerId,
        roles: [
          GuildRole(
            id: _guildId,
            name: '@everyone',
            color: 0,
            position: 0,
            permissions: Permissions.none.withFlag(PermissionFlag.sendMessages),
            hoist: false,
            mentionable: false,
            unicodeEmoji: null,
          ),
        ],
      );

      expect(perms.has(PermissionFlag.sendMessages), isTrue);
    });

    test('unions permissions across every role the member holds', () {
      const roleAId = Snowflake(10);
      const roleBId = Snowflake(11);
      final perms = effectiveGuildPermissions(
        member: _guildMember(roleIds: const [roleAId, roleBId]),
        guildId: _guildId,
        guildOwnerId: _ownerId,
        roles: [
          _everyoneRole,
          GuildRole(
            id: roleAId,
            name: 'A',
            color: 0,
            position: 1,
            permissions: Permissions.none.withFlag(PermissionFlag.kickMembers),
            hoist: false,
            mentionable: false,
            unicodeEmoji: null,
          ),
          GuildRole(
            id: roleBId,
            name: 'B',
            color: 0,
            position: 2,
            permissions: Permissions.none.withFlag(PermissionFlag.banMembers),
            hoist: false,
            mentionable: false,
            unicodeEmoji: null,
          ),
        ],
      );

      expect(perms.has(PermissionFlag.kickMembers), isTrue);
      expect(perms.has(PermissionFlag.banMembers), isTrue);
    });

    test('a role with administrator implies every other permission', () {
      const adminRoleId = Snowflake(20);
      final perms = effectiveGuildPermissions(
        member: _guildMember(roleIds: const [adminRoleId]),
        guildId: _guildId,
        guildOwnerId: _ownerId,
        roles: [
          _everyoneRole,
          GuildRole(
            id: adminRoleId,
            name: 'Admin',
            color: 0,
            position: 1,
            permissions: Permissions.none.withFlag(
              PermissionFlag.administrator,
            ),
            hoist: false,
            mentionable: false,
            unicodeEmoji: null,
          ),
        ],
      );

      expect(perms.has(PermissionFlag.manageGuild), isTrue);
    });

    test('a member with no roles has no permissions beyond @everyone', () {
      final perms = effectiveGuildPermissions(
        member: _guildMember(),
        guildId: _guildId,
        guildOwnerId: _ownerId,
        roles: const [_everyoneRole],
      );

      expect(perms.has(PermissionFlag.manageMessages), isFalse);
    });
  });
}
