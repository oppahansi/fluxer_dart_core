import 'guild_role.dart';
import 'snowflake.dart';

/// A Fluxer guild. Modeled after `GuildResponse` in Fluxer's OpenAPI spec —
/// M1 covers identity, ownership, and roles; channels/emojis/stickers are
/// fetched separately via `fluxer_rest` for now rather than embedded here,
/// and land as embedded fields in M2 once `fluxer_rest` has managers for
/// them.
final class Guild {
  const Guild({
    required this.id,
    required this.name,
    required this.icon,
    required this.ownerId,
    required this.roles,
    required this.memberCount,
  });

  /// Decodes the flat shape REST returns (`GuildResponse`): guild fields
  /// live directly on [json].
  factory Guild.fromJson(Map<String, dynamic> json) => Guild(
    id: Snowflake.parse(json['id'] as String),
    name: json['name'] as String,
    icon: json['icon'] as String?,
    ownerId: Snowflake.parse(json['owner_id'] as String),
    roles: (json['roles'] as List<dynamic>? ?? const [])
        .map((r) => GuildRole.fromJson(r as Map<String, dynamic>))
        .toList(growable: false),
    memberCount: json['member_count'] as int?,
  );

  /// Decodes the `GUILD_CREATE`/READY gateway dispatch shape
  /// (`GuildReadyData` in the reference client), which is *not* flat like
  /// [fromJson]'s REST shape — guild fields (name, icon, owner_id, ...)
  /// are nested under a `properties` object, sibling to `id`, `roles`,
  /// and `member_count` at the top level. Found by actually running this
  /// against a live instance: `Guild.fromJson` crashed on a null
  /// `owner_id` because it isn't at the top level in this payload at all.
  factory Guild.fromGuildCreateJson(Map<String, dynamic> json) =>
      Guild.fromJson({
        ...(json['properties'] as Map<String, dynamic>? ?? const {}),
        'id': json['id'],
        'roles': json['roles'],
        'member_count': json['member_count'],
      });

  final Snowflake id;
  final String name;
  final String? icon;
  final Snowflake ownerId;
  final List<GuildRole> roles;
  final int? memberCount;

  @override
  bool operator ==(Object other) => other is Guild && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Guild($id, $name)';
}
