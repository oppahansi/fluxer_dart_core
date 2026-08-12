import 'snowflake.dart';

/// A Fluxer user, as embedded in messages, mentions, and similar contexts.
///
/// Modeled after `UserPartialResponse` in Fluxer's OpenAPI spec — the
/// partial/public shape returned alongside other resources, as opposed to
/// the fuller `UserPrivateResponse` shape only the authenticated user sees
/// about themselves (not modeled here).
final class User {
  const User({
    required this.id,
    required this.username,
    required this.discriminator,
    required this.globalName,
    required this.avatar,
    required this.avatarColor,
    required this.bot,
    required this.system,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: Snowflake.parse(json['id'] as String),
    username: json['username'] as String,
    discriminator: json['discriminator'] as String,
    globalName: json['global_name'] as String?,
    avatar: json['avatar'] as String?,
    avatarColor: json['avatar_color'] as int?,
    bot: json['bot'] as bool? ?? false,
    system: json['system'] as bool? ?? false,
  );

  final Snowflake id;
  final String username;
  final String discriminator;
  final String? globalName;
  final String? avatar;
  final int? avatarColor;
  final bool bot;
  final bool system;

  /// The name Fluxer displays for this user: [globalName] if set, falling
  /// back to [username].
  String get displayName => globalName ?? username;

  User copyWith({
    Snowflake? id,
    String? username,
    String? discriminator,
    String? Function()? globalName,
    String? Function()? avatar,
    int? Function()? avatarColor,
    bool? bot,
    bool? system,
  }) => User(
    id: id ?? this.id,
    username: username ?? this.username,
    discriminator: discriminator ?? this.discriminator,
    globalName: globalName != null ? globalName() : this.globalName,
    avatar: avatar != null ? avatar() : this.avatar,
    avatarColor: avatarColor != null ? avatarColor() : this.avatarColor,
    bot: bot ?? this.bot,
    system: system ?? this.system,
  );

  @override
  bool operator ==(Object other) => other is User && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'User($id, $username)';
}
