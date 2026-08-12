import 'snowflake.dart';

/// One entry in a guild's audit log. Modeled after
/// `GuildAuditLogEntryResponse` in Fluxer's OpenAPI spec — deliberately
/// only the fields common to every action type ([actionType] itself,
/// who did it, what it targeted, why, and the raw per-action [options]
/// map). Fluxer has ~35 action types with meaningfully different
/// `options`/`changes` shapes; typing each one is real work with a much
/// smaller payoff than the rest of this ecosystem's models, and nothing
/// needs more than "list recent entries" yet.
final class GuildAuditLogEntry {
  const GuildAuditLogEntry({
    required this.id,
    required this.actionType,
    required this.userId,
    required this.targetId,
    required this.reason,
    required this.options,
  });

  factory GuildAuditLogEntry.fromJson(Map<String, dynamic> json) =>
      GuildAuditLogEntry(
        id: Snowflake.parse(json['id'] as String),
        actionType: json['action_type'] as int,
        userId: (json['user_id'] as String?)?.let(Snowflake.parse),
        targetId: json['target_id'] as String?,
        reason: json['reason'] as String?,
        options: json['options'] as Map<String, dynamic>? ?? const {},
      );

  final Snowflake id;

  /// The raw `action_type` wire value — see `AuditLogActionType` in
  /// Fluxer's OpenAPI spec for the full name-to-value mapping (e.g. `10`
  /// is `MEMBER_KICK`, `20` is `ROLE_CREATE`).
  final int actionType;

  /// The user who performed the action, when known.
  final Snowflake? userId;

  /// The affected entity's ID — a user, channel, role, or invite code
  /// depending on [actionType]. Left as a raw string since which kind of
  /// ID it is isn't self-describing without also branching on
  /// [actionType].
  final String? targetId;
  final String? reason;

  /// Action-specific extra data (e.g. `channel_id` for a message
  /// deletion, `role_name` for a role action). Shape varies by
  /// [actionType] — see the spec's `AuditLogEntryOptions` for the full
  /// per-action field list.
  final Map<String, dynamic> options;

  @override
  bool operator ==(Object other) =>
      other is GuildAuditLogEntry && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'GuildAuditLogEntry($id, actionType=$actionType)';
}

extension _Let<T> on T? {
  R? let<R>(R Function(T) f) {
    final self = this;
    return self == null ? null : f(self);
  }
}
