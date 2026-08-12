import 'guild_role.dart';
import 'snowflake.dart';

/// A Fluxer guild. Modeled after `GuildResponse` in Fluxer's OpenAPI spec:
/// identity, ownership, and roles. Channels, emojis, and stickers are
/// fetched separately via `fluxer_dart_rest`'s managers rather than embedded
/// here.
final class Guild {
  const Guild({
    required this.id,
    required this.name,
    required this.icon,
    required this.ownerId,
    required this.roles,
    required this.memberCount,
    required this.onlineCount,
    required this.vanityUrlCode,
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
    onlineCount: json['online_count'] as int?,
    vanityUrlCode: json['vanity_url_code'] as String?,
  );

  /// Decodes the `GUILD_CREATE`/READY gateway dispatch shape
  /// (`GuildReadyData` in the reference client), which is *not* flat like
  /// [fromJson]'s REST shape — guild fields (name, icon, owner_id, ...)
  /// are nested under a `properties` object, sibling to `id`, `roles`,
  /// and `member_count` at the top level.
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
  final int? onlineCount;

  /// The guild's custom invite code (`fluxer.app/i/<code>`), if the
  /// `VANITY_URL` feature is enabled — `null` otherwise.
  final String? vanityUrlCode;

  @override
  bool operator ==(Object other) => other is Guild && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Guild($id, $name)';
}
