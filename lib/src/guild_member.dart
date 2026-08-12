import 'snowflake.dart';
import 'user.dart';

/// A guild member. Modeled after `GuildMemberResponse` in Fluxer's
/// OpenAPI spec, confirmed against a live instance's
/// `GET /guilds/{id}/members` response.
final class GuildMember {
  const GuildMember({
    required this.user,
    required this.nick,
    required this.avatar,
    required this.roleIds,
    required this.joinedAt,
    required this.mute,
    required this.deaf,
    required this.communicationDisabledUntil,
  });

  factory GuildMember.fromJson(Map<String, dynamic> json) => GuildMember(
    user: User.fromJson(json['user'] as Map<String, dynamic>),
    nick: json['nick'] as String?,
    avatar: json['avatar'] as String?,
    roleIds: (json['roles'] as List<dynamic>)
        .map((r) => Snowflake.parse(r as String))
        .toList(growable: false),
    joinedAt: DateTime.parse(json['joined_at'] as String),
    mute: json['mute'] as bool,
    deaf: json['deaf'] as bool,
    communicationDisabledUntil:
        (json['communication_disabled_until'] as String?) == null
        ? null
        : DateTime.parse(json['communication_disabled_until'] as String),
  );

  final User user;
  final String? nick;
  final String? avatar;
  final List<Snowflake> roleIds;
  final DateTime joinedAt;
  final bool mute;
  final bool deaf;

  /// If set and in the future, this member is timed out until then.
  final DateTime? communicationDisabledUntil;

  /// The name Fluxer displays for this member in this guild: [nick] if
  /// set, falling back to [User.displayName].
  String get displayName => nick ?? user.displayName;

  bool get isTimedOut =>
      communicationDisabledUntil != null &&
      communicationDisabledUntil!.isAfter(DateTime.now());

  @override
  bool operator ==(Object other) =>
      other is GuildMember && other.user.id == user.id;

  @override
  int get hashCode => user.id.hashCode;

  @override
  String toString() => 'GuildMember(${user.id}, $displayName)';
}
