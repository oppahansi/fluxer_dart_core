import 'guild_member.dart';
import 'profile_badge.dart';
import 'snowflake.dart';
import 'user.dart';

/// A user's profile from `GET /users/{id}/profile`.
///
/// [guildMember] and [guildBio] and the other guild fields are present
/// only when the request named a guild; [mutualGuilds] only when asked
/// for.
final class UserProfile {
  const UserProfile({
    required this.user,
    required this.bio,
    required this.pronouns,
    required this.banner,
    required this.accentColor,
    required this.timezoneOffset,
    this.guildMember,
    this.guildBio,
    this.guildPronouns,
    this.mutualGuilds = const [],
    this.badges = const [],
    this.operatorPassSince,
    this.hiddenBadgeCount,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final profile = json['user_profile'] as Map<String, dynamic>? ?? const {};
    final guildProfile = json['guild_member_profile'] as Map<String, dynamic>?;
    return UserProfile(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      bio: profile['bio'] as String?,
      pronouns: profile['pronouns'] as String?,
      banner: profile['banner'] as String?,
      accentColor: profile['accent_color'] as int?,
      timezoneOffset: json['timezone_offset'] as int?,
      guildMember: switch (json['guild_member']) {
        final Map<String, dynamic> m => GuildMember.fromJson(m),
        _ => null,
      },
      guildBio: guildProfile?['bio'] as String?,
      guildPronouns: guildProfile?['pronouns'] as String?,
      mutualGuilds: [
        for (final g in json['mutual_guilds'] as List<dynamic>? ?? const [])
          (
            id: Snowflake.parse((g as Map<String, dynamic>)['id'] as String),
            nick: g['nick'] as String?,
          ),
      ],
      badges: [
        for (final b in json['profile_badges'] as List<dynamic>? ?? const [])
          ProfileBadge.fromJson(b as Map<String, dynamic>),
      ],
      operatorPassSince: switch (json['operator_pass_since']) {
        final String s => DateTime.parse(s),
        _ => null,
      },
      hiddenBadgeCount: json['hidden_profile_badge_count'] as int?,
    );
  }

  final User user;
  final String? bio;
  final String? pronouns;
  final String? banner;
  final int? accentColor;

  /// Minutes from UTC, when the user shares it.
  final int? timezoneOffset;

  final GuildMember? guildMember;

  /// The user's bio and pronouns in the requested guild, overriding the
  /// account-wide ones there.
  final String? guildBio;
  final String? guildPronouns;

  /// Guilds this bot shares with the user, with the user's nickname in
  /// each.
  final List<({Snowflake id, String? nick})> mutualGuilds;

  /// The badges to display, in display order. Empty when there is nothing
  /// to show.
  final List<ProfileBadge> badges;

  /// When the user got the Operator Pass; `null` when they have none or
  /// hide it.
  final DateTime? operatorPassSince;

  /// How many of the user's badges are hidden from other people. Present
  /// only on the requesting account's own profile.
  final int? hiddenBadgeCount;

  @override
  String toString() => 'UserProfile(${user.id})';
}
