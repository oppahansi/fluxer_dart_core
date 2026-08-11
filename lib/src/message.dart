import 'snowflake.dart';
import 'user.dart';

/// Message flags, verified against `packages/constants/src/ChannelConstants.ts`
/// (`export const MessageFlags`) in the Fluxer source. Deliberately small —
/// unlike [PermissionFlag][], Fluxer only has four of these right now.
///
/// [PermissionFlag]: package:fluxer_core/src/permissions.dart
enum MessageFlag {
  suppressEmbeds(1 << 2),
  suppressNotifications(1 << 12),
  voiceMessage(1 << 13),
  compactAttachments(1 << 17);

  const MessageFlag(this.bit);

  final int bit;
}

/// A Fluxer message. Modeled after `MessageResponseSchema` in Fluxer's
/// OpenAPI spec: covers plain text content. Embeds, attachments,
/// reactions, and message references are not yet modeled.
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

  bool hasFlag(MessageFlag flag) => flags & flag.bit == flag.bit;

  @override
  bool operator ==(Object other) => other is Message && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Message($id, from ${author.username}: "$content")';
}
