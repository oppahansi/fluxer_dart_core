import 'attachment.dart';
import 'embed.dart';
import 'message_reference.dart';
import 'snowflake.dart';
import 'user.dart';

/// Message flags, verified against `packages/constants/src/ChannelConstants.ts`
/// (`export const MessageFlags`) in the Fluxer source. Deliberately small —
/// unlike [PermissionFlag][], Fluxer only has four of these right now.
///
/// [PermissionFlag]: package:fluxer_dart_core/src/permissions.dart
enum MessageFlag {
  suppressEmbeds(1 << 2),
  suppressNotifications(1 << 12),
  voiceMessage(1 << 13),
  compactAttachments(1 << 17);

  const MessageFlag(this.bit);

  final int bit;
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
