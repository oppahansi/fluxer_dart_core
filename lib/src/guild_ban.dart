import 'snowflake.dart';
import 'user.dart';

/// A guild ban record. Modeled after `GuildBanResponse` in Fluxer's
/// OpenAPI spec.
final class GuildBan {
  const GuildBan({
    required this.user,
    required this.reason,
    required this.moderatorId,
    required this.bannedAt,
    required this.expiresAt,
  });

  factory GuildBan.fromJson(Map<String, dynamic> json) => GuildBan(
    user: User.fromJson(json['user'] as Map<String, dynamic>),
    reason: json['reason'] as String?,
    moderatorId: Snowflake.parse(json['moderator_id'] as String),
    bannedAt: DateTime.parse(json['banned_at'] as String),
    expiresAt: (json['expires_at'] as String?) == null
        ? null
        : DateTime.parse(json['expires_at'] as String),
  );

  final User user;
  final String? reason;
  final Snowflake moderatorId;
  final DateTime bannedAt;

  /// `null` means permanent.
  final DateTime? expiresAt;

  @override
  bool operator ==(Object other) =>
      other is GuildBan && other.user.id == user.id;

  @override
  int get hashCode => user.id.hashCode;

  @override
  String toString() => 'GuildBan(${user.id}, ${user.username})';
}
