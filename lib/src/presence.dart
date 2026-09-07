import 'snowflake.dart';

/// The availability a session advertises.
///
/// `invisible` is a client-side choice that other users see as `offline`;
/// both values are accepted on the wire.
enum PresenceStatus {
  online('online'),
  idle('idle'),
  doNotDisturb('dnd'),
  invisible('invisible'),
  offline('offline');

  const PresenceStatus(this.value);

  /// The wire value, which differs from the Dart name for
  /// [PresenceStatus.doNotDisturb].
  final String value;

  static PresenceStatus? tryFromValue(String value) {
    for (final candidate in values) {
      if (candidate.value == value) return candidate;
    }
    return null;
  }
}

/// The free-text status line shown beside a user's name.
///
/// [emojiId] and [emojiName] are mutually exclusive: a custom guild emoji
/// is identified by id, a standard emoji by its Unicode character in
/// [emojiName].
final class CustomStatus {
  const CustomStatus({this.text, this.expiresAt, this.emojiId, this.emojiName});

  factory CustomStatus.fromJson(Map<String, dynamic> json) => CustomStatus(
    text: json['text'] as String?,
    expiresAt: (json['expires_at'] as String?)?.let(DateTime.parse),
    emojiId: (json['emoji_id'] as String?)?.let(Snowflake.parse),
    emojiName: json['emoji_name'] as String?,
  );

  /// 1-128 characters.
  final String? text;

  /// When set, the status clears itself at this time.
  final DateTime? expiresAt;

  final Snowflake? emojiId;

  /// A Unicode emoji character, 1-32 characters.
  final String? emojiName;

  Map<String, dynamic> toJson() => {
    if (text != null) 'text': text,
    if (expiresAt != null) 'expires_at': expiresAt!.toUtc().toIso8601String(),
    if (emojiId != null) 'emoji_id': emojiId!.toJson(),
    if (emojiName != null) 'emoji_name': emojiName,
  };

  @override
  String toString() => 'CustomStatus($text)';
}

/// The presence a session publishes, sent either as part of IDENTIFY or
/// on its own to replace the current one.
final class Presence {
  const Presence({
    required this.status,
    this.afk = false,
    this.mobile = false,
    this.customStatus,
  });

  final PresenceStatus status;

  /// Marks the session away for notification routing.
  final bool afk;

  /// Marks the session as a mobile client.
  final bool mobile;

  /// Omitted from an update leaves the existing status in place; clearing
  /// it requires sending an explicit null, which [toJson] emits when
  /// [clearCustomStatus] built this value.
  final CustomStatus? customStatus;

  /// A presence that removes any custom status currently set.
  static Presence clearCustomStatus(PresenceStatus status) =>
      _ClearingPresence(status: status);

  Map<String, dynamic> toJson() => {
    'status': status.value,
    if (afk) 'afk': true,
    if (mobile) 'mobile': true,
    if (customStatus != null) 'custom_status': customStatus!.toJson(),
  };

  @override
  String toString() => 'Presence(${status.value})';
}

final class _ClearingPresence extends Presence {
  const _ClearingPresence({required super.status});

  @override
  Map<String, dynamic> toJson() => {...super.toJson(), 'custom_status': null};
}

extension _Let<T> on T {
  R let<R>(R Function(T) f) => f(this);
}

/// One of an account's live gateway sessions, as reported by
/// `SESSIONS_REPLACE`.
///
/// The set always includes a synthetic entry whose [sessionId] is the
/// literal `all`, carrying the account's aggregate presence rather than
/// any one connection's — [isAggregate] distinguishes it.
final class SessionPresence {
  const SessionPresence({
    required this.sessionId,
    required this.status,
    required this.afk,
    required this.mobile,
  });

  factory SessionPresence.fromJson(Map<String, dynamic> json) =>
      SessionPresence(
        sessionId: json['session_id'] as String,
        status:
            PresenceStatus.tryFromValue(json['status'] as String? ?? '') ??
            PresenceStatus.offline,
        afk: json['afk'] as bool? ?? false,
        mobile: json['mobile'] as bool? ?? false,
      );

  /// A gateway session id, or `all` for the aggregate entry.
  final String sessionId;

  final PresenceStatus status;
  final bool afk;
  final bool mobile;

  /// Whether this is the account-wide aggregate rather than a single
  /// connection.
  bool get isAggregate => sessionId == 'all';

  @override
  String toString() => 'SessionPresence($sessionId, ${status.value})';
}
