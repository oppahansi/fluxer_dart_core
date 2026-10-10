import 'channel_type.dart';
import 'forum.dart';
import 'snowflake.dart';
import 'thread.dart';

/// A Fluxer channel.
///
/// Sealed so callers get exhaustive-`switch` safety: adding a new channel
/// type variant later is a compile error at every call site that doesn't
/// handle it, rather than a silent runtime gap. Modeled after
/// `ChannelResponse` in Fluxer's OpenAPI spec.
///
/// [ChannelType.guildLink] and [ChannelType.dmPersonalNotes] (both
/// Fluxer-specific, low-traffic types), along with any type this version
/// of `fluxer_dart_core` doesn't recognize at all, decode to [UnknownChannel]
/// rather than throwing.
sealed class Channel {
  const Channel({required this.id, required this.type, required this.name});

  factory Channel.fromJson(Map<String, dynamic> json) {
    final rawType = json['type'] as int;
    final type = ChannelType.tryFromValue(rawType);
    final id = Snowflake.parse(json['id'] as String);
    final name = json['name'] as String?;

    return switch (type) {
      ChannelType.guildText => GuildTextChannel(
        id: id,
        name: name!,
        guildId: Snowflake.parse(json['guild_id'] as String),
        topic: json['topic'] as String?,
        position: json['position'] as int? ?? 0,
        parentId: (json['parent_id'] as String?).let(Snowflake.parse),
        lastMessageId: (json['last_message_id'] as String?).let(
          Snowflake.parse,
        ),
        nsfw: json['nsfw'] as bool? ?? false,
        rateLimitPerUser: json['rate_limit_per_user'] as int? ?? 0,
      ),
      ChannelType.dm => DmChannel(
        id: id,
        recipientIds: _recipientIds(json),
        lastMessageId: (json['last_message_id'] as String?).let(
          Snowflake.parse,
        ),
      ),
      ChannelType.guildVoice => GuildVoiceChannel(
        id: id,
        name: name!,
        guildId: Snowflake.parse(json['guild_id'] as String),
        position: json['position'] as int? ?? 0,
        parentId: (json['parent_id'] as String?).let(Snowflake.parse),
        bitrate: json['bitrate'] as int?,
        userLimit: json['user_limit'] as int?,
        voiceConnectionLimit: json['voice_connection_limit'] as int?,
        rtcRegion: json['rtc_region'] as String?,
      ),
      ChannelType.groupDm => GroupDmChannel(
        id: id,
        name: name,
        icon: json['icon'] as String?,
        ownerId: (json['owner_id'] as String?).let(Snowflake.parse),
        recipientIds: _recipientIds(json),
        lastMessageId: (json['last_message_id'] as String?).let(
          Snowflake.parse,
        ),
      ),
      ChannelType.guildAnnouncement => GuildAnnouncementChannel(
        id: id,
        name: name!,
        guildId: Snowflake.parse(json['guild_id'] as String),
        topic: json['topic'] as String?,
        position: json['position'] as int? ?? 0,
        parentId: (json['parent_id'] as String?).let(Snowflake.parse),
        lastMessageId: (json['last_message_id'] as String?).let(
          Snowflake.parse,
        ),
        nsfw: json['nsfw'] as bool? ?? false,
        rateLimitPerUser: json['rate_limit_per_user'] as int? ?? 0,
      ),
      ChannelType.guildCategory => GuildCategoryChannel(
        id: id,
        name: name!,
        guildId: Snowflake.parse(json['guild_id'] as String),
        position: json['position'] as int? ?? 0,
      ),
      ChannelType.guildForum || ChannelType.guildMedia => GuildForumChannel(
        id: id,
        type: type!,
        name: name!,
        guildId: Snowflake.parse(json['guild_id'] as String),
        topic: json['topic'] as String?,
        position: json['position'] as int? ?? 0,
        parentId: (json['parent_id'] as String?).let(Snowflake.parse),
        lastPostId: (json['last_message_id'] as String?).let(Snowflake.parse),
        nsfw: json['nsfw'] as bool? ?? false,
        rateLimitPerUser: json['rate_limit_per_user'] as int? ?? 0,
        flags: json['flags'] as int? ?? 0,
        availableTags: (json['available_tags'] as List<dynamic>? ?? const [])
            .map((t) => ForumTag.fromJson(t as Map<String, dynamic>))
            .toList(growable: false),
        defaultThreadRateLimitPerUser:
            json['default_thread_rate_limit_per_user'] as int? ?? 0,
      ),
      ChannelType.announcementThread ||
      ChannelType.publicThread ||
      ChannelType.privateThread => ThreadChannel.fromJson(json),
      _ => UnknownChannel(id: id, type: type, rawType: rawType, name: name),
    };
  }

  final Snowflake id;
  final ChannelType? type;
  final String? name;

  /// The guild this channel belongs to, or `null` for a channel kind
  /// with no guild (a DM or group DM). Every guild-scoped variant
  /// carries its own `guildId` field; this just unifies them behind one
  /// getter so callers that only care "is this guild-scoped, and if so
  /// which one" don't need their own exhaustive `switch`.
  Snowflake? get guildId => switch (this) {
    GuildTextChannel(:final guildId) => guildId,
    GuildAnnouncementChannel(:final guildId) => guildId,
    GuildVoiceChannel(:final guildId) => guildId,
    GuildCategoryChannel(:final guildId) => guildId,
    GuildForumChannel(:final guildId) => guildId,
    ThreadChannel(:final guildId) => guildId,
    DmChannel() || GroupDmChannel() || UnknownChannel() => null,
  };

  Map<String, dynamic> toJson();
}

List<Snowflake> _recipientIds(Map<String, dynamic> json) =>
    ((json['recipients'] as List<dynamic>?) ?? const [])
        .map(
          (r) => Snowflake.parse((r as Map<String, dynamic>)['id'] as String),
        )
        .toList(growable: false);

final class GuildTextChannel extends Channel {
  const GuildTextChannel({
    required super.id,
    required String super.name,
    required this.guildId,
    required this.topic,
    required this.position,
    required this.parentId,
    required this.lastMessageId,
    required this.nsfw,
    required this.rateLimitPerUser,
  }) : super(type: ChannelType.guildText);

  @override
  final Snowflake guildId;
  final String? topic;
  final int position;
  final Snowflake? parentId;
  final Snowflake? lastMessageId;
  final bool nsfw;
  final int rateLimitPerUser;

  @override
  Map<String, dynamic> toJson() => {
    'id': id.toJson(),
    'type': ChannelType.guildText.value,
    'name': name,
    'guild_id': guildId.toJson(),
    'topic': topic,
    'position': position,
    'parent_id': parentId?.toJson(),
    'last_message_id': lastMessageId?.toJson(),
    'nsfw': nsfw,
    'rate_limit_per_user': rateLimitPerUser,
  };

  @override
  String toString() => 'GuildTextChannel($id, #$name)';
}

/// A guild channel whose messages can be published to channels in other
/// guilds that follow it.
///
/// Carries the same shape as [GuildTextChannel] and behaves like one for
/// sending; the difference is that a message in it can be crossposted,
/// and other guilds can follow it to receive copies.
final class GuildAnnouncementChannel extends Channel {
  const GuildAnnouncementChannel({
    required super.id,
    required String super.name,
    required this.guildId,
    required this.topic,
    required this.position,
    required this.parentId,
    required this.lastMessageId,
    required this.nsfw,
    required this.rateLimitPerUser,
  }) : super(type: ChannelType.guildAnnouncement);

  @override
  final Snowflake guildId;
  final String? topic;
  final int position;
  final Snowflake? parentId;
  final Snowflake? lastMessageId;
  final bool nsfw;
  final int rateLimitPerUser;

  @override
  Map<String, dynamic> toJson() => {
    'id': id.toJson(),
    'type': ChannelType.guildAnnouncement.value,
    'name': name,
    'guild_id': guildId.toJson(),
    'topic': topic,
    'position': position,
    'parent_id': parentId?.toJson(),
    'last_message_id': lastMessageId?.toJson(),
    'nsfw': nsfw,
    'rate_limit_per_user': rateLimitPerUser,
  };

  @override
  String toString() => 'GuildAnnouncementChannel($id, #$name)';
}

final class DmChannel extends Channel {
  const DmChannel({
    required super.id,
    required this.recipientIds,
    required this.lastMessageId,
  }) : super(type: ChannelType.dm, name: null);

  final List<Snowflake> recipientIds;
  final Snowflake? lastMessageId;

  @override
  Map<String, dynamic> toJson() => {
    'id': id.toJson(),
    'type': ChannelType.dm.value,
    'recipients': recipientIds.map((r) => {'id': r.toJson()}).toList(),
    'last_message_id': lastMessageId?.toJson(),
  };

  @override
  String toString() => 'DmChannel($id)';
}

final class GuildVoiceChannel extends Channel {
  const GuildVoiceChannel({
    required super.id,
    required String super.name,
    required this.guildId,
    required this.position,
    required this.parentId,
    required this.bitrate,
    required this.userLimit,
    required this.voiceConnectionLimit,
    required this.rtcRegion,
  }) : super(type: ChannelType.guildVoice);

  @override
  final Snowflake guildId;
  final int position;
  final Snowflake? parentId;
  final int? bitrate;
  final int? userLimit;
  final int? voiceConnectionLimit;

  /// `null` means automatic region selection.
  final String? rtcRegion;

  @override
  Map<String, dynamic> toJson() => {
    'id': id.toJson(),
    'type': ChannelType.guildVoice.value,
    'name': name,
    'guild_id': guildId.toJson(),
    'position': position,
    'parent_id': parentId?.toJson(),
    'bitrate': bitrate,
    'user_limit': userLimit,
    'voice_connection_limit': voiceConnectionLimit,
    'rtc_region': rtcRegion,
  };

  @override
  String toString() => 'GuildVoiceChannel($id, #$name)';
}

final class GroupDmChannel extends Channel {
  const GroupDmChannel({
    required super.id,
    required super.name,
    required this.icon,
    required this.ownerId,
    required this.recipientIds,
    required this.lastMessageId,
  }) : super(type: ChannelType.groupDm);

  final String? icon;

  /// The member who created (and can manage) this group DM.
  final Snowflake? ownerId;
  final List<Snowflake> recipientIds;
  final Snowflake? lastMessageId;

  @override
  Map<String, dynamic> toJson() => {
    'id': id.toJson(),
    'type': ChannelType.groupDm.value,
    'name': name,
    'icon': icon,
    'owner_id': ownerId?.toJson(),
    'recipients': recipientIds.map((r) => {'id': r.toJson()}).toList(),
    'last_message_id': lastMessageId?.toJson(),
  };

  @override
  String toString() => 'GroupDmChannel($id, $name)';
}

final class GuildCategoryChannel extends Channel {
  const GuildCategoryChannel({
    required super.id,
    required String super.name,
    required this.guildId,
    required this.position,
  }) : super(type: ChannelType.guildCategory);

  @override
  final Snowflake guildId;
  final int position;

  @override
  Map<String, dynamic> toJson() => {
    'id': id.toJson(),
    'type': ChannelType.guildCategory.value,
    'name': name,
    'guild_id': guildId.toJson(),
    'position': position,
  };

  @override
  String toString() => 'GuildCategoryChannel($id, $name)';
}

/// A forum or media channel: a channel that holds posts, each of which is
/// a [ThreadChannel], and accepts no message of its own.
///
/// [type] is [ChannelType.guildForum] or [ChannelType.guildMedia]. The
/// two share one shape; a media channel is a forum that can additionally
/// set [ChannelFlag.hideMediaDownloadOptions].
final class GuildForumChannel extends Channel {
  const GuildForumChannel({
    required super.id,
    required ChannelType super.type,
    required String super.name,
    required this.guildId,
    required this.topic,
    required this.position,
    required this.parentId,
    required this.lastPostId,
    required this.nsfw,
    required this.rateLimitPerUser,
    required this.flags,
    required this.availableTags,
    required this.defaultThreadRateLimitPerUser,
  });

  @override
  final Snowflake guildId;

  /// The channel's posting guidelines.
  final String? topic;
  final int position;
  final Snowflake? parentId;

  /// The newest post, sent on the wire as `last_message_id`.
  final Snowflake? lastPostId;
  final bool nsfw;

  /// Seconds one member must wait between creating posts.
  final int rateLimitPerUser;

  /// Raw [ChannelFlag] bitfield.
  final int flags;

  /// The tags a post can apply, at most 20.
  final List<ForumTag> availableTags;

  /// The slowmode, in seconds, a new post inherits when its create
  /// request names none.
  final int defaultThreadRateLimitPerUser;

  bool get isMedia => type == ChannelType.guildMedia;

  /// Whether a new post must apply at least one tag.
  bool get requiresTag => hasFlag(ChannelFlag.requireTag);

  bool hasFlag(ChannelFlag flag) => flags & flag.bit == flag.bit;

  @override
  Map<String, dynamic> toJson() => {
    'id': id.toJson(),
    'type': type!.value,
    'name': name,
    'guild_id': guildId.toJson(),
    'topic': topic,
    'position': position,
    'parent_id': parentId?.toJson(),
    'last_message_id': lastPostId?.toJson(),
    'nsfw': nsfw,
    'rate_limit_per_user': rateLimitPerUser,
    'flags': flags,
    'available_tags': availableTags.map((t) => t.toJson()).toList(),
    'default_thread_rate_limit_per_user': defaultThreadRateLimitPerUser,
  };

  @override
  String toString() => 'GuildForumChannel($id, #$name)';
}

/// A thread: a channel inside a text, announcement, forum or media
/// channel that holds its own messages. A forum or media post is a
/// thread of type [ChannelType.publicThread].
///
/// A thread stores no permission overwrites. Its permissions are those
/// of [parentId], with `sendMessagesInThreads` standing in for
/// `sendMessages`.
///
/// A thread started from a message has that message's id.
final class ThreadChannel extends Channel {
  const ThreadChannel({
    required super.id,
    required ChannelType super.type,
    required String super.name,
    required this.guildId,
    required this.parentId,
    required this.ownerId,
    required this.lastMessageId,
    required this.rateLimitPerUser,
    required this.flags,
    required this.metadata,
    required this.messageCount,
    required this.totalMessageSent,
    required this.memberCount,
    this.appliedTagIds = const [],
    this.member,
  });

  factory ThreadChannel.fromJson(Map<String, dynamic> json) => ThreadChannel(
    id: Snowflake.parse(json['id'] as String),
    type: ChannelType.fromValue(json['type'] as int),
    name: json['name'] as String? ?? '',
    guildId: Snowflake.parse(json['guild_id'] as String),
    parentId: Snowflake.parse(json['parent_id'] as String),
    ownerId: (json['owner_id'] as String?).let(Snowflake.parse),
    lastMessageId: (json['last_message_id'] as String?).let(Snowflake.parse),
    rateLimitPerUser: json['rate_limit_per_user'] as int? ?? 0,
    flags: json['flags'] as int? ?? 0,
    metadata: ThreadMetadata.fromJson(
      json['thread_metadata'] as Map<String, dynamic>,
    ),
    messageCount: json['message_count'] as int? ?? 0,
    totalMessageSent: json['total_message_sent'] as int? ?? 0,
    memberCount: json['member_count'] as int? ?? 0,
    appliedTagIds: (json['applied_tags'] as List<dynamic>? ?? const [])
        .map((t) => Snowflake.parse(t as String))
        .toList(growable: false),
    member: (json['member'] as Map<String, dynamic>?).let(
      ThreadMember.fromJson,
    ),
  );

  @override
  final Snowflake guildId;

  /// The text, announcement, forum or media channel the thread is in.
  final Snowflake parentId;

  /// The user or webhook that created the thread.
  final Snowflake? ownerId;
  final Snowflake? lastMessageId;
  final int rateLimitPerUser;

  /// Raw [ChannelFlag] bitfield. Only [ChannelFlag.pinned] is ever set,
  /// and only on a forum or media post.
  final int flags;

  final ThreadMetadata metadata;

  /// Messages currently in the thread, not counting the first message of
  /// a forum post or anything deleted.
  final int messageCount;

  /// Messages ever sent in the thread. Deleting one does not lower it.
  final int totalMessageSent;

  /// Number of thread members, capped at 50.
  final int memberCount;

  /// The forum tags applied to a post. Empty on a thread outside a forum
  /// or media channel.
  final List<Snowflake> appliedTagIds;

  /// The caller's own membership, where the payload carries it. Its
  /// absence does not by itself mean the caller is not a member: thread
  /// listings report memberships beside the threads instead.
  final ThreadMember? member;

  bool get isArchived => metadata.archived;
  bool get isLocked => metadata.locked;
  bool get isPrivate => type == ChannelType.privateThread;

  /// Whether this is the pinned post of its forum or media channel.
  bool get isPinned => hasFlag(ChannelFlag.pinned);

  bool hasFlag(ChannelFlag flag) => flags & flag.bit == flag.bit;

  @override
  Map<String, dynamic> toJson() => {
    'id': id.toJson(),
    'type': type!.value,
    'name': name,
    'guild_id': guildId.toJson(),
    'parent_id': parentId.toJson(),
    'owner_id': ownerId?.toJson(),
    'last_message_id': lastMessageId?.toJson(),
    'rate_limit_per_user': rateLimitPerUser,
    'flags': flags,
    'thread_metadata': metadata.toJson(),
    'message_count': messageCount,
    'total_message_sent': totalMessageSent,
    'member_count': memberCount,
    if (appliedTagIds.isNotEmpty)
      'applied_tags': appliedTagIds.map((t) => t.toJson()).toList(),
    if (member != null) 'member': member!.toJson(),
  };

  @override
  String toString() => 'ThreadChannel($id, "$name")';
}

/// A channel of a known-but-unmodeled type ([ChannelType.guildLink],
/// [ChannelType.dmPersonalNotes]), or of a type this version of
/// `fluxer_dart_core` doesn't recognize at all. Carries [rawType] so callers
/// can still branch on the raw integer.
final class UnknownChannel extends Channel {
  const UnknownChannel({
    required super.id,
    required super.type,
    required this.rawType,
    required super.name,
  });

  final int rawType;

  @override
  Map<String, dynamic> toJson() => {
    'id': id.toJson(),
    'type': rawType,
    'name': name,
  };

  @override
  String toString() => 'UnknownChannel($id, rawType=$rawType)';
}

extension _Let<T> on T? {
  R? let<R>(R Function(T) f) {
    final self = this;
    return self == null ? null : f(self);
  }
}
