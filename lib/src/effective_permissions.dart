import 'guild_member.dart';
import 'guild_role.dart';
import 'permissions.dart';
import 'snowflake.dart';

/// Computes [member]'s effective guild-level permissions: the guild
/// owner always has every permission; otherwise it's the union of
/// [roles] the member holds, including the `@everyone` role (its ID
/// always equals [guildId] itself, matching Discord's convention —
/// confirmed against a live instance's own role list, not assumed) —
/// `@everyone` applies to every member regardless of whether it appears
/// in [member]'s own role list, which it never does. [Permissions.has]
/// already treats `administrator` as implying every other flag, so that
/// doesn't need special-casing here.
///
/// Deliberately guild-level only — this doesn't merge in channel
/// permission overwrites, so it can be wrong for a member who's been
/// denied something at the channel level despite holding it at the
/// guild level. See the bot roadmap's own note on why that's out of
/// scope for now.
Permissions effectiveGuildPermissions({
  required GuildMember member,
  required Snowflake guildId,
  required Snowflake guildOwnerId,
  required List<GuildRole> roles,
}) {
  if (member.user.id == guildOwnerId) return Permissions.all;

  var combined = Permissions.none;
  for (final role in roles) {
    if (role.id == guildId || member.roleIds.contains(role.id)) {
      combined |= role.permissions;
    }
  }
  return combined;
}
