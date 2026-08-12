import 'snowflake.dart';
import 'user.dart';

/// An invite. Modeled after `GuildInviteResponse` in Fluxer's OpenAPI
/// spec, which leaves `guild` as an untyped `object` and `channel` as its
/// own partial shape distinct from the full channel response — this only
/// pulls out the identity/name fields, not a full nested [Guild]/`Channel`.
final class Invite {
  const Invite({
    required this.code,
    required this.guildId,
    required this.guildName,
    required this.channelId,
    required this.channelName,
    required this.inviter,
    required this.memberCount,
    required this.presenceCount,
    required this.expiresAt,
    required this.temporary,
  });

  factory Invite.fromJson(Map<String, dynamic> json) {
    final guild = json['guild'] as Map<String, dynamic>?;
    final channel = json['channel'] as Map<String, dynamic>;
    return Invite(
      code: json['code'] as String,
      guildId: guild == null ? null : Snowflake.parse(guild['id'] as String),
      guildName: guild?['name'] as String?,
      channelId: Snowflake.parse(channel['id'] as String),
      channelName: channel['name'] as String?,
      inviter: (json['inviter'] as Map<String, dynamic>?)?.let(User.fromJson),
      memberCount: json['member_count'] as int,
      presenceCount: json['presence_count'] as int,
      expiresAt: (json['expires_at'] as String?)?.let(DateTime.parse),
      temporary: json['temporary'] as bool,
    );
  }

  final String code;
  final Snowflake? guildId;
  final String? guildName;
  final Snowflake channelId;
  final String? channelName;
  final User? inviter;
  final int memberCount;
  final int presenceCount;

  /// `null` means this invite never expires.
  final DateTime? expiresAt;
  final bool temporary;

  @override
  bool operator ==(Object other) => other is Invite && other.code == code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => 'Invite($code)';
}

extension _Let<T> on T {
  R let<R>(R Function(T) f) => f(this);
}
