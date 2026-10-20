import 'permissions.dart';
import 'snowflake.dart';

/// A role within a guild. Modeled after `GuildRoleResponse` in Fluxer's
/// OpenAPI spec.
final class GuildRole {
  const GuildRole({
    required this.id,
    required this.name,
    required this.color,
    required this.position,
    this.hoistPosition,
    required this.permissions,
    required this.hoist,
    required this.mentionable,
    required this.unicodeEmoji,
  });

  factory GuildRole.fromJson(Map<String, dynamic> json) => GuildRole(
    id: Snowflake.parse(json['id'] as String),
    name: json['name'] as String,
    color: json['color'] as int,
    position: json['position'] as int,
    hoistPosition: json['hoist_position'] as int?,
    permissions: Permissions.fromJson(json['permissions'] as String),
    hoist: json['hoist'] as bool,
    mentionable: json['mentionable'] as bool,
    unicodeEmoji: json['unicode_emoji'] as String?,
  );

  final Snowflake id;
  final String name;
  final int color;
  final int position;

  /// The role's place among the member list's hoisted groups. `null`
  /// until set through `PATCH /guilds/{id}/roles/hoist-positions`, and
  /// again after those positions are reset.
  final int? hoistPosition;

  final Permissions permissions;
  final bool hoist;
  final bool mentionable;
  final String? unicodeEmoji;

  @override
  bool operator ==(Object other) => other is GuildRole && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'GuildRole($id, $name)';
}
