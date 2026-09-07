import 'attachment.dart';
import 'embed.dart';
import 'message_reference.dart';
import 'snowflake.dart';
import 'user.dart';

/// Per-message behaviour flags.
///
/// Only [suppressEmbeds], [suppressNotifications] and [voiceMessage] can
/// be set by a client on send; [compactAttachments] appears on incoming
/// messages but is not accepted in a send or edit body.
enum MessageFlag {
  /// Serialise the message without its embeds, including any link
  /// preview the server would otherwise generate.
  suppressEmbeds(1 << 2),

  /// Deliver the message without a push or desktop notification.
  suppressNotifications(1 << 12),

  voiceMessage(1 << 13),

  compactAttachments(1 << 17);

  const MessageFlag(this.bit);

  final int bit;
}

/// A set of [MessageFlag]s, held as the integer bitfield the API uses.
extension type const MessageFlags(int value) {
  /// No flags set.
  static const MessageFlags none = MessageFlags(0);

  factory MessageFlags.of(Iterable<MessageFlag> flags) =>
      MessageFlags(flags.fold(0, (bits, flag) => bits | flag.bit));

  bool has(MessageFlag flag) => value & flag.bit == flag.bit;

  MessageFlags operator |(MessageFlag flag) => MessageFlags(value | flag.bit);

  /// The flags this bitfield names, ignoring any bit with no known flag.
  Iterable<MessageFlag> get flags => MessageFlag.values.where(has);
}

/// A Fluxer message. Modeled after `MessageResponseSchema` in Fluxer's
/// OpenAPI spec: text content, embeds, attachments, and message
/// references. Reactions and sticker items on an incoming message aren't
/// modeled yet — nothing reads them so far.
final class Message {
  const Message({
    required this.id,
    required this.channelId,
    required this.author,
    required this.type,
    required this.flags,
    required this.content,
    required this.timestamp,
    required this.editedTimestamp,
    required this.pinned,
    required this.mentionEveryone,
    required this.tts,
    required this.mentions,
    required this.mentionRoleIds,
    this.embeds = const [],
    this.attachments = const [],
    this.messageReference,
    this.referencedMessage,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: Snowflake.parse(json['id'] as String),
    channelId: Snowflake.parse(json['channel_id'] as String),
    author: User.fromJson(json['author'] as Map<String, dynamic>),
    type: json['type'] as int,
    flags: json['flags'] as int? ?? 0,
    content: json['content'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    editedTimestamp: (json['edited_timestamp'] as String?) == null
        ? null
        : DateTime.parse(json['edited_timestamp'] as String),
    pinned: json['pinned'] as bool,
    mentionEveryone: json['mention_everyone'] as bool,
    tts: json['tts'] as bool,
    mentions: (json['mentions'] as List<dynamic>)
        .map((m) => User.fromJson(m as Map<String, dynamic>))
        .toList(growable: false),
    mentionRoleIds: (json['mention_roles'] as List<dynamic>)
        .map((r) => Snowflake.parse(r as String))
        .toList(growable: false),
    embeds: (json['embeds'] as List<dynamic>? ?? const [])
        .map((e) => Embed.fromJson(e as Map<String, dynamic>))
        .toList(growable: false),
    attachments: (json['attachments'] as List<dynamic>? ?? const [])
        .map((a) => Attachment.fromJson(a as Map<String, dynamic>))
        .toList(growable: false),
    messageReference: (json['message_reference'] as Map<String, dynamic>?)?.let(
      MessageReference.fromJson,
    ),
    referencedMessage: (json['referenced_message'] as Map<String, dynamic>?)
        ?.let(Message.fromJson),
  );

  final Snowflake id;
  final Snowflake channelId;
  final User author;
  final int type;
  final int flags;
  final String content;
  final DateTime timestamp;
  final DateTime? editedTimestamp;
  final bool pinned;
  final bool mentionEveryone;
  final bool tts;
  final List<User> mentions;
  final List<Snowflake> mentionRoleIds;
  final List<Embed> embeds;
  final List<Attachment> attachments;
  final MessageReference? messageReference;

  /// The full replied-to message, present when Fluxer resolves it inline
  /// rather than leaving the caller to fetch [messageReference] itself.
  final Message? referencedMessage;

  bool hasFlag(MessageFlag flag) => flags & flag.bit == flag.bit;

  @override
  bool operator ==(Object other) => other is Message && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Message($id, from ${author.username}: "$content")';
}

extension _Let<T> on T? {
  R? let<R>(R Function(T) f) {
    final self = this;
    return self == null ? null : f(self);
  }
}

/// A message together with the time it was pinned.
///
/// Pin listings return this rather than a bare message, because the pin
/// order is by pin time and that is not derivable from the message.
final class PinnedMessage {
  const PinnedMessage({required this.message, required this.pinnedAt});

  factory PinnedMessage.fromJson(Map<String, dynamic> json) => PinnedMessage(
    message: Message.fromJson(json['message'] as Map<String, dynamic>),
    pinnedAt: DateTime.parse(json['pinned_at'] as String),
  );

  final Message message;
  final DateTime pinnedAt;

  @override
  String toString() => 'PinnedMessage(${message.id} at $pinnedAt)';
}
