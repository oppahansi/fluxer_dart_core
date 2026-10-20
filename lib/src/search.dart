import 'channel.dart';
import 'guild_member.dart';
import 'message.dart';
import 'thread.dart';

/// A page of `POST /search/messages` results.
///
/// When the search index is still being built the server answers
/// `{"indexing": true}` with no results; [indexing] is then true and the
/// lists are empty. Retry later.
final class MessageSearchResults {
  const MessageSearchResults({
    required this.messages,
    required this.channels,
    required this.threads,
    required this.members,
    required this.total,
    required this.hitsPerPage,
    required this.page,
    this.cursor = const [],
    this.indexing = false,
  });

  factory MessageSearchResults.fromJson(Map<String, dynamic> json) {
    if (json['indexing'] == true) {
      return const MessageSearchResults(
        messages: [],
        channels: [],
        threads: [],
        members: [],
        total: 0,
        hitsPerPage: 0,
        page: 0,
        indexing: true,
      );
    }
    List<T> list<T>(String key, T Function(Map<String, dynamic>) decode) =>
        (json[key] as List<dynamic>? ?? const [])
            .map((e) => decode(e as Map<String, dynamic>))
            .toList(growable: false);
    return MessageSearchResults(
      messages: list('messages', Message.fromJson),
      channels: list('channels', Channel.fromJson),
      threads: list('threads', ThreadChannel.fromJson),
      members: list('members', ThreadMember.fromJson),
      total: json['total'] as int? ?? 0,
      hitsPerPage: json['hits_per_page'] as int? ?? 0,
      page: json['page'] as int? ?? 0,
      cursor: (json['cursor'] as List<dynamic>? ?? const [])
          .cast<String>()
          .toList(growable: false),
    );
  }

  final List<Message> messages;

  /// The channels the hits were found in.
  final List<Channel> channels;

  /// The threads the hits were found in, with this bot's memberships of
  /// them in [members].
  final List<ThreadChannel> threads;
  final List<ThreadMember> members;

  /// Total matches across every page.
  final int total;
  final int hitsPerPage;
  final int page;

  /// Opaque continuation for the next page, when the server sent one.
  final List<String> cursor;

  final bool indexing;
}

/// A page of `GET /channels/{id}/threads/search` results.
///
/// When the search index is not ready the server answers 202 instead;
/// [retryAfter] is then set and the lists are empty.
final class ThreadSearchResults {
  const ThreadSearchResults({
    required this.threads,
    required this.members,
    required this.firstMessages,
    required this.hasMore,
    required this.totalResults,
    this.retryAfter,
  });

  factory ThreadSearchResults.fromJson(Map<String, dynamic> json) {
    if (json['code'] == 'SEARCH_INDEX_NOT_READY') {
      return ThreadSearchResults(
        threads: const [],
        members: const [],
        firstMessages: const [],
        hasMore: false,
        totalResults: 0,
        retryAfter: Duration(
          milliseconds: (((json['retry_after'] as num?) ?? 1) * 1000).round(),
        ),
      );
    }
    List<T> list<T>(String key, T Function(Map<String, dynamic>) decode) =>
        (json[key] as List<dynamic>? ?? const [])
            .map((e) => decode(e as Map<String, dynamic>))
            .toList(growable: false);
    return ThreadSearchResults(
      threads: list('threads', ThreadChannel.fromJson),
      members: list('members', ThreadMember.fromJson),
      firstMessages: list('first_messages', Message.fromJson),
      hasMore: json['has_more'] as bool? ?? false,
      totalResults: json['total_results'] as int? ?? 0,
    );
  }

  final List<ThreadChannel> threads;

  /// This bot's memberships of [threads].
  final List<ThreadMember> members;

  /// The opening message of each post, for a forum or media channel.
  final List<Message> firstMessages;
  final bool hasMore;
  final int totalResults;

  /// Set when the index was not ready and the search should be retried
  /// after this long.
  final Duration? retryAfter;

  bool get indexReady => retryAfter == null;
}

/// What a forum lists for a post without opening it: who started it and
/// its first message. Either can be `null` once deleted.
final class ForumPostData {
  const ForumPostData({required this.owner, required this.firstMessage});

  factory ForumPostData.fromJson(Map<String, dynamic> json) => ForumPostData(
    owner: switch (json['owner']) {
      final Map<String, dynamic> m => GuildMember.fromJson(m),
      _ => null,
    },
    firstMessage: switch (json['first_message']) {
      final Map<String, dynamic> m => Message.fromJson(m),
      _ => null,
    },
  );

  final GuildMember? owner;
  final Message? firstMessage;
}
