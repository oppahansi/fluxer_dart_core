import 'attachment.dart';
import 'channel.dart';
import 'embed.dart';
import 'guild_member.dart';
import 'message_reference.dart';
import 'reaction_emoji.dart';
import 'snowflake.dart';
import 'user.dart';

/// Per-message behaviour flags.
///
/// Only [suppressEmbeds], [suppressNotifications] and [voiceMessage] can
/// be set by a client on send. The rest describe state the API sets
/// itself and are rejected in a send or edit body.
enum MessageFlag {
  /// Set on an announcement-channel message that has been published to
  /// following channels.
  crossposted(1 << 0),

  /// Set on a copy delivered to a channel that follows an announcement
  /// channel.
  isCrosspost(1 << 1),

  /// Serialise the message without its embeds, including any link
  /// preview the server would otherwise generate.
  suppressEmbeds(1 << 2),

  /// Set on surviving copies once the published message they came from is
  /// deleted. The copy stays in place as a placeholder.
  sourceMessageDeleted(1 << 3),

  /// Set on a message a thread was started from. [Message.thread] holds
  /// the thread.
  hasThread(1 << 5),

  /// Set when a role mention in a thread could not add every member of
  /// the role to the thread.
  failedToMentionSomeRolesInThread(1 << 8),

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

/// What produced a message.
///
/// Most messages are [default_]; the rest are system messages the API
/// writes itself to narrate something that happened in the channel.
enum MessageType {
  default_(0),
  recipientAdd(1),
  recipientRemove(2),
  call(3),
  channelNameChange(4),
  channelIconChange(5),
  channelPinnedMessage(6),
  userJoin(7),

  /// Written into a channel when it starts following an announcement
  /// channel.
  channelFollowAdd(12),

  /// Written into the parent channel when a public or announcement
  /// thread is started. Its [Message.messageReference] names the thread
  /// as a channel and carries no message id.
  threadCreated(18),

  reply(19),

  /// The first message of a thread started from a message. It has the
  /// thread's id, empty content, and the source message as its
  /// [Message.referencedMessage].
  threadStarterMessage(21);

  const MessageType(this.value);

  final int value;

  /// `null` for a value this version does not recognise, which callers
  /// handle through [Message.rawType] instead of a thrown error.
  static MessageType? tryFromValue(int value) {
    for (final candidate in values) {
      if (candidate.value == value) return candidate;
    }
    return null;
  }
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
    required this.rawType,
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
    this.thread,
    this.webhookId,
    this.stickers = const [],
    this.reactions = const [],
    this.nonce,
    this.guildId,
    this.member,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: Snowflake.parse(json['id'] as String),
    channelId: Snowflake.parse(json['channel_id'] as String),
    author: User.fromJson(json['author'] as Map<String, dynamic>),
    rawType: json['type'] as int,
    flags: MessageFlags(json['flags'] as int? ?? 0),
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
    thread: (json['thread'] as Map<String, dynamic>?)?.let(
      ThreadChannel.fromJson,
    ),
    webhookId: (json['webhook_id'] as String?)?.let(Snowflake.parse),
    stickers: (json['stickers'] as List<dynamic>? ?? const [])
        .map((s) => MessageSticker.fromJson(s as Map<String, dynamic>))
        .toList(growable: false),
    reactions: (json['reactions'] as List<dynamic>? ?? const [])
        .map((r) => MessageReaction.fromJson(r as Map<String, dynamic>))
        .toList(growable: false),
    nonce: json['nonce']?.toString(),
    guildId: (json['guild_id'] as String?)?.let(Snowflake.parse),
    // On a gateway message event the member's own `user` is removed;
    // the account is the message's `author`.
    member: (json['member'] as Map<String, dynamic>?)?.let(
      (m) => GuildMember.fromJson({'user': json['author'], ...m}),
    ),
  );

  final Snowflake id;
  final Snowflake channelId;
  final User author;

  /// The wire value of [type], kept so a type this version does not model
  /// is still readable.
  final int rawType;

  final MessageFlags flags;

  /// What produced this message, or `null` for a type this version does
  /// not model — see [rawType].
  MessageType? get type => MessageType.tryFromValue(rawType);

  /// Whether this message has been published to channels following its
  /// announcement channel.
  bool get isCrossposted => flags.has(MessageFlag.crossposted);

  /// Whether this message is a copy delivered by following an
  /// announcement channel rather than being sent here directly.
  bool get isCrosspost => flags.has(MessageFlag.isCrosspost);
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

  /// The thread started from this message, present while
  /// [MessageFlag.hasThread] is set. It has this message's id.
  final ThreadChannel? thread;

  /// The webhook that posted this message; [author] is then a stand-in
  /// carrying the webhook's name, not a real account.
  final Snowflake? webhookId;

  final List<MessageSticker> stickers;

  /// Reaction totals per emoji.
  final List<MessageReaction> reactions;

  /// The value the sender attached to recognise its own message.
  final String? nonce;

  /// Present on gateway message events in a guild, together with
  /// [member]; REST responses carry neither.
  final Snowflake? guildId;

  /// The author's guild member, on gateway message events in a guild.
  final GuildMember? member;

  /// Whether a webhook, rather than a user or bot account, posted this.
  bool get isWebhook => webhookId != null;

  bool hasFlag(MessageFlag flag) => flags.has(flag);

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

/// A sticker as a message carries it.
final class MessageSticker {
  const MessageSticker({
    required this.id,
    required this.name,
    required this.animated,
  });

  factory MessageSticker.fromJson(Map<String, dynamic> json) => MessageSticker(
    id: Snowflake.parse(json['id'] as String),
    name: json['name'] as String,
    animated: json['animated'] as bool? ?? false,
  );

  final Snowflake id;
  final String name;
  final bool animated;
}

/// How many times one emoji was reacted to a message, and whether this
/// bot is one of them.
final class MessageReaction {
  const MessageReaction({
    required this.emoji,
    required this.count,
    required this.me,
  });

  factory MessageReaction.fromJson(Map<String, dynamic> json) =>
      MessageReaction(
        emoji: ReactionEmoji.fromJson(json['emoji'] as Map<String, dynamic>),
        count: json['count'] as int,
        me: json['me'] as bool? ?? false,
      );

  final ReactionEmoji emoji;
  final int count;
  final bool me;
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
