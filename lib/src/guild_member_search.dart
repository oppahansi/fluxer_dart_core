import 'snowflake.dart';

/// One member matched by a guild member search.
///
/// This is the search index's own flattened shape, not a [GuildMember][]:
/// user identity and guild membership are merged into one object, and
/// [joinedAt] arrives as a Unix timestamp rather than the ISO 8601 string
/// the member routes return.
///
/// [GuildMember]: package:fluxer_dart_core/src/guild_member.dart
final class GuildMemberSearchResult {
  const GuildMemberSearchResult({
    required this.guildId,
    required this.userId,
    required this.username,
    required this.discriminator,
    required this.globalName,
    required this.nickname,
    required this.roleIds,
    required this.joinedAt,
  });

  factory GuildMemberSearchResult.fromJson(Map<String, dynamic> json) =>
      GuildMemberSearchResult(
        guildId: Snowflake.parse(json['guild_id'] as String),
        userId: Snowflake.parse(json['user_id'] as String),
        username: json['username'] as String,
        discriminator: json['discriminator'] as String,
        globalName: json['global_name'] as String?,
        nickname: json['nickname'] as String?,
        roleIds:
            (json['role_ids'] as List<dynamic>?)
                ?.map((r) => Snowflake.parse(r as String))
                .toList(growable: false) ??
            const [],
        joinedAt: switch (json['joined_at']) {
          final num seconds => DateTime.fromMillisecondsSinceEpoch(
            (seconds * 1000).round(),
            isUtc: true,
          ),
          _ => null,
        },
      );

  final Snowflake guildId;
  final Snowflake userId;
  final String username;

  /// Zero-padded four digits.
  final String discriminator;

  final String? globalName;

  /// The member's per-guild nickname, if set.
  final String? nickname;

  final List<Snowflake> roleIds;

  /// Decoded from a Unix timestamp, unlike the member routes' ISO 8601
  /// string.
  final DateTime? joinedAt;

  /// The nickname if set, otherwise the global name, otherwise the
  /// username.
  String get displayName => nickname ?? globalName ?? username;

  @override
  String toString() => 'GuildMemberSearchResult($username#$discriminator)';
}

/// One page of guild member search results.
final class GuildMemberSearchPage {
  const GuildMemberSearchPage({
    required this.guildId,
    required this.members,
    required this.totalResultCount,
    required this.indexing,
  });

  factory GuildMemberSearchPage.fromJson(Map<String, dynamic> json) =>
      GuildMemberSearchPage(
        guildId: Snowflake.parse(json['guild_id'] as String),
        members: (json['members'] as List<dynamic>)
            .map(
              (m) =>
                  GuildMemberSearchResult.fromJson(m as Map<String, dynamic>),
            )
            .toList(growable: false),
        totalResultCount: json['total_result_count'] as int? ?? 0,
        indexing: json['indexing'] as bool? ?? false,
      );

  final Snowflake guildId;
  final List<GuildMemberSearchResult> members;

  /// Total matches, which may exceed the number returned in this page.
  final int totalResultCount;

  /// Whether the guild's member index is still being built. Results are
  /// incomplete while this is true.
  final bool indexing;

  @override
  String toString() =>
      'GuildMemberSearchPage(${members.length} of $totalResultCount)';
}
