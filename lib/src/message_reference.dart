import 'snowflake.dart';

/// What kind of pointer a [MessageReference] is.
enum MessageReferenceType {
  /// A reply.
  reply(0),

  /// A forwarded message.
  forward(1);

  const MessageReferenceType(this.value);

  final int value;

  /// `null` for a value this version does not recognise.
  static MessageReferenceType? tryFromValue(int value) {
    for (final candidate in values) {
      if (candidate.value == value) return candidate;
    }
    return null;
  }
}

/// A reference from one message to somewhere else — what a reply or a
/// forward points at.
///
/// [channelId] and [guildId] are only meaningful when decoding an
/// existing reference; sending a same-channel reply needs only
/// [messageId], so [toJson] omits the rest when unset.
///
/// [messageId] is nullable because not every reference names a message: a
/// `CHANNEL_FOLLOW_ADD` system message carries a reference to the
/// announcement channel being followed, with a channel and guild but no
/// message.
final class MessageReference {
  const MessageReference({
    required this.messageId,
    this.channelId,
    this.guildId,
    this.type,
  });

  factory MessageReference.fromJson(Map<String, dynamic> json) =>
      MessageReference(
        messageId: (json['message_id'] as String?)?.let(Snowflake.parse),
        channelId: (json['channel_id'] as String?)?.let(Snowflake.parse),
        guildId: (json['guild_id'] as String?)?.let(Snowflake.parse),
        type: switch (json['type']) {
          final int raw => MessageReferenceType.tryFromValue(raw),
          _ => null,
        },
      );

  /// `null` on a reference that points at a channel rather than a
  /// message.
  final Snowflake? messageId;
  final Snowflake? channelId;
  final Snowflake? guildId;

  /// `null` when absent, or a type this version does not model.
  final MessageReferenceType? type;

  Map<String, dynamic> toJson() => {
    if (messageId != null) 'message_id': messageId!.toJson(),
    if (channelId != null) 'channel_id': channelId!.toJson(),
    if (guildId != null) 'guild_id': guildId!.toJson(),
  };
}

extension _Let<T> on T? {
  R? let<R>(R Function(T) f) {
    final self = this;
    return self == null ? null : f(self);
  }
}
