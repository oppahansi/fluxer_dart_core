import 'snowflake.dart';

/// A reference to another message — what a reply or forward points at.
/// Modeled after `MessageReferenceRequest`/the `message_reference` field
/// of `MessageResponseSchema` in Fluxer's OpenAPI spec.
///
/// [channelId]/[guildId] are only meaningful when decoding an existing
/// reference (a cross-channel/cross-guild forward); sending a same-
/// channel reply only needs [messageId], so [toJson] omits them when
/// unset rather than sending redundant/incorrect values.
final class MessageReference {
  const MessageReference({
    required this.messageId,
    this.channelId,
    this.guildId,
  });

  factory MessageReference.fromJson(Map<String, dynamic> json) =>
      MessageReference(
        messageId: Snowflake.parse(json['message_id'] as String),
        channelId: (json['channel_id'] as String?)?.let(Snowflake.parse),
        guildId: (json['guild_id'] as String?)?.let(Snowflake.parse),
      );

  final Snowflake messageId;
  final Snowflake? channelId;
  final Snowflake? guildId;

  Map<String, dynamic> toJson() => {
    'message_id': messageId.toJson(),
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
