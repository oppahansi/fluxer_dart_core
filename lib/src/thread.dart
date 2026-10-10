import 'channel.dart';
import 'guild_member.dart';
import 'message.dart';
import 'snowflake.dart';

/// How long a thread stays active without a message before it is archived.
///
/// These four are the only values the API accepts.
enum ThreadAutoArchiveDuration {
  oneHour(60),
  oneDay(1440),

  /// What a thread gets when the create request names no duration.
  threeDays(4320),
  oneWeek(10080);

  const ThreadAutoArchiveDuration(this.minutes);

  final int minutes;

  Duration get duration => Duration(minutes: minutes);
}

/// The archive and lock state of a thread.
final class ThreadMetadata {
  const ThreadMetadata({
    required this.archived,
    required this.autoArchiveMinutes,
    required this.archiveTimestamp,
    required this.locked,
    required this.invitable,
    required this.createdAt,
  });

  factory ThreadMetadata.fromJson(Map<String, dynamic> json) => ThreadMetadata(
    archived: json['archived'] as bool,
    autoArchiveMinutes: json['auto_archive_duration'] as int,
    archiveTimestamp: DateTime.parse(json['archive_timestamp'] as String),
    locked: json['locked'] as bool,
    invitable: json['invitable'] as bool?,
    createdAt: DateTime.parse(json['create_timestamp'] as String),
  );

  final bool archived;

  /// Minutes of inactivity after which the thread is archived. Kept as
  /// the wire integer rather than a [ThreadAutoArchiveDuration] so an
  /// unrecognised value still decodes.
  final int autoArchiveMinutes;

  /// When the thread was last archived, unarchived, or given a new auto
  /// archive duration. Equal to [createdAt] until the first of those.
  final DateTime archiveTimestamp;

  /// Whether only thread moderators can act in the thread.
  final bool locked;

  /// Whether a member who is not a thread moderator can add others.
  /// Present only on a private thread, `null` otherwise.
  final bool? invitable;

  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'archived': archived,
    'auto_archive_duration': autoArchiveMinutes,
    'archive_timestamp': archiveTimestamp.toUtc().toIso8601String(),
    'locked': locked,
    'invitable': ?invitable,
    'create_timestamp': createdAt.toUtc().toIso8601String(),
  };
}

/// Per-member thread state flags.
enum ThreadMemberFlag {
  /// The user created the thread or sent a message in it. Set only by
  /// the API; a bot that creates a thread starts without it.
  hasInteracted(1 << 0),

  /// Notify the user of every message in the thread.
  allMessages(1 << 1),

  /// Notify the user only of mentions in the thread.
  onlyMentions(1 << 2),

  /// Notify the user of nothing in the thread.
  noMessages(1 << 3);

  const ThreadMemberFlag(this.bit);

  final int bit;
}

/// A record that a user joined a thread.
///
/// The same object appears in several places with different fields
/// filled in, which is why most of them are nullable:
///
/// - [threadId] and [userId] are absent on the `member` of a thread
///   inside a guild's thread list at connect.
/// - [muted] is present only on the caller's own membership.
/// - [member] is present only when a REST call asked for it with
///   `withMember`, and on each entry a `THREAD_MEMBERS_UPDATE` adds.
final class ThreadMember {
  const ThreadMember({
    required this.threadId,
    required this.userId,
    required this.joinedAt,
    required this.flags,
    this.muted,
    this.member,
  });

  factory ThreadMember.fromJson(Map<String, dynamic> json) => ThreadMember(
    threadId: switch (json['id']) {
      final String id => Snowflake.parse(id),
      _ => null,
    },
    userId: switch (json['user_id']) {
      final String id => Snowflake.parse(id),
      _ => null,
    },
    joinedAt: DateTime.parse(json['join_timestamp'] as String),
    flags: json['flags'] as int? ?? 0,
    muted: json['muted'] as bool?,
    member: switch (json['member']) {
      final Map<String, dynamic> member => GuildMember.fromJson(member),
      _ => null,
    },
  );

  final Snowflake? threadId;
  final Snowflake? userId;

  /// When the user last joined the thread. Leaving and rejoining resets
  /// it.
  final DateTime joinedAt;

  /// Raw [ThreadMemberFlag] bitfield.
  final int flags;

  /// Whether the caller muted the thread, or `null` on someone else's
  /// membership.
  final bool? muted;

  /// The user's guild member, where the payload carries it.
  final GuildMember? member;

  bool hasFlag(ThreadMemberFlag flag) => flags & flag.bit == flag.bit;

  Map<String, dynamic> toJson() => {
    if (threadId != null) 'id': threadId!.toJson(),
    if (userId != null) 'user_id': userId!.toJson(),
    'join_timestamp': joinedAt.toUtc().toIso8601String(),
    'flags': flags,
    'muted': ?muted,
  };

  @override
  String toString() => 'ThreadMember(thread: $threadId, user: $userId)';
}

/// A set of threads together with the caller's memberships in them.
///
/// Thread listings return the two side by side rather than nesting each
/// membership in its thread, so [memberFor] does the join.
final class ThreadList {
  const ThreadList({
    required this.threads,
    required this.members,
    this.hasMore = false,
  });

  factory ThreadList.fromJson(Map<String, dynamic> json) => ThreadList(
    threads: (json['threads'] as List<dynamic>)
        .map((t) => ThreadChannel.fromJson(t as Map<String, dynamic>))
        .toList(growable: false),
    members: (json['members'] as List<dynamic>? ?? const [])
        .map((m) => ThreadMember.fromJson(m as Map<String, dynamic>))
        .toList(growable: false),
    hasMore: json['has_more'] as bool? ?? false,
  );

  final List<ThreadChannel> threads;

  /// One entry for each of [threads] the caller has joined.
  final List<ThreadMember> members;

  /// Whether a later request can return more. Always false for the
  /// active-thread listing, which is not paged.
  final bool hasMore;

  /// The caller's membership in [threadId], or `null` if it has not
  /// joined that thread.
  ThreadMember? memberFor(Snowflake threadId) {
    for (final member in members) {
      if (member.threadId == threadId) return member;
    }
    return null;
  }

  @override
  String toString() =>
      'ThreadList(${threads.length} threads, hasMore: $hasMore)';
}

/// A newly created forum or media post: the thread plus its first
/// message, which shares the thread's id.
final class ForumPost {
  const ForumPost({required this.thread, required this.message});

  factory ForumPost.fromJson(Map<String, dynamic> json) => ForumPost(
    thread: ThreadChannel.fromJson(json),
    message: Message.fromJson(json['message'] as Map<String, dynamic>),
  );

  final ThreadChannel thread;
  final Message message;

  @override
  String toString() => 'ForumPost(${thread.id}, "${thread.name}")';
}
